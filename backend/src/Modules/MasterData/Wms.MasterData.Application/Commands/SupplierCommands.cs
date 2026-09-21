using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Domain;
using Wms.MasterData.Domain.Entities;

namespace Wms.MasterData.Application.Commands;

/// <summary>The commercial and contact block shared by <c>SupplierCreate</c> and <c>SupplierUpdate</c>.</summary>
public sealed record SupplierProfile(
    string Name,
    string? TaxId,
    string? ContactPerson,
    string? Phone,
    string? Email,
    string? Address,
    string? BankDetails,
    string Currency,
    string? PaymentTerms,
    string? DeliveryTerms,
    string? Incoterms,
    bool IsApprovedFoodSupplier);

internal static class SupplierProfileRules
{
    public static void Apply<T>(AbstractValidator<T> validator, Func<T, SupplierProfile> selector)
        where T : class
    {
        validator.RuleFor(c => selector(c).Name).NotEmpty().MaximumLength(Supplier.NameMaxLength).OverridePropertyName("name");
        validator.RuleFor(c => selector(c).TaxId).MaximumLength(32).OverridePropertyName("taxId");
        validator.RuleFor(c => selector(c).ContactPerson).MaximumLength(150).OverridePropertyName("contactPerson");
        validator.RuleFor(c => selector(c).Phone).MaximumLength(64).OverridePropertyName("phone");
        validator.RuleFor(c => selector(c).Email).MaximumLength(200).EmailAddress()
            .When(c => !string.IsNullOrWhiteSpace(selector(c).Email)).OverridePropertyName("email");
        validator.RuleFor(c => selector(c).Address).MaximumLength(500).OverridePropertyName("address");
        validator.RuleFor(c => selector(c).BankDetails).MaximumLength(500).OverridePropertyName("bankDetails");
        validator.RuleFor(c => selector(c).Currency).NotEmpty().Matches("^[A-Z]{3}$").OverridePropertyName("currency");
        validator.RuleFor(c => selector(c).PaymentTerms).MaximumLength(200).OverridePropertyName("paymentTerms");
        validator.RuleFor(c => selector(c).DeliveryTerms).MaximumLength(200).OverridePropertyName("deliveryTerms");
        validator.RuleFor(c => selector(c).Incoterms).MaximumLength(16).OverridePropertyName("incoterms");
    }

    public static Result Apply(Supplier supplier, SupplierProfile profile)
    {
        var renamed = supplier.Rename(profile.Name);
        if (renamed.IsFailure)
        {
            return renamed;
        }

        var currency = supplier.ChangeCurrency(profile.Currency);
        if (currency.IsFailure)
        {
            return currency;
        }

        supplier.SetTaxId(profile.TaxId);
        supplier.SetContactDetails(profile.ContactPerson, profile.Phone, profile.Email, profile.Address);
        supplier.SetCommercialTerms(profile.BankDetails, profile.PaymentTerms, profile.DeliveryTerms, profile.Incoterms);
        supplier.SetFoodApproval(profile.IsApprovedFoodSupplier);
        return Result.Success();
    }
}

// ==================================================================== create

/// <summary><c>POST /masterdata/suppliers</c>.</summary>
public sealed record CreateSupplierCommand(string Code, SupplierProfile Profile) : ICommand<uint>;

public sealed class CreateSupplierCommandValidator : AbstractValidator<CreateSupplierCommand>
{
    public CreateSupplierCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$")
            .WithMessage("code must match ^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$.");
        RuleFor(c => c.Profile).NotNull();
        SupplierProfileRules.Apply(this, c => c.Profile);
    }
}

public sealed class CreateSupplierCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    ISupplierRepository suppliers,
    ITenantContext tenantContext) : ICommandHandler<CreateSupplierCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(CreateSupplierCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var code = Supplier.NormalizeCode(command.Code);
        if (await suppliers.CodeExistsAsync(code, null, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.SupplierCodeAlreadyExists(code);
        }

        var created = Supplier.Create(tenantContext.TenantId, code, command.Profile.Name, command.Profile.Currency, command.Profile.TaxId);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var supplier = created.Value;
        var applied = SupplierProfileRules.Apply(supplier, command.Profile);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        suppliers.Add(supplier);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.Supplier,
            supplier.Id,
            AuditAction.Create,
            new { supplier.Code, supplier.Name, supplier.Currency, supplier.IsApprovedFoodSupplier });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return supplier.Id;
    }
}

// ==================================================================== update

/// <summary><c>PUT /masterdata/suppliers/{id}</c>.</summary>
public sealed record UpdateSupplierCommand(uint SupplierId, uint RowVersion, string Code, SupplierProfile Profile, bool IsActive) : ICommand<uint>;

public sealed class UpdateSupplierCommandValidator : AbstractValidator<UpdateSupplierCommand>
{
    public UpdateSupplierCommandValidator()
    {
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$")
            .WithMessage("code must match ^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$.");
        RuleFor(c => c.Profile).NotNull();
        SupplierProfileRules.Apply(this, c => c.Profile);
    }
}

public sealed class UpdateSupplierCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    ISupplierRepository suppliers,
    ITenantContext tenantContext) : ICommandHandler<UpdateSupplierCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(UpdateSupplierCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var supplier = await suppliers.GetAsync(command.SupplierId, cancellationToken).ConfigureAwait(false);
        if (supplier is null)
        {
            return MasterDataErrors.SupplierNotFound(command.SupplierId);
        }

        if (supplier.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var code = Supplier.NormalizeCode(command.Code);
        if (!string.Equals(code, supplier.Code, StringComparison.Ordinal)
            && await suppliers.CodeExistsAsync(code, supplier.Id, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.SupplierCodeAlreadyExists(code);
        }

        var changedCode = supplier.ChangeCode(code);
        if (changedCode.IsFailure)
        {
            return changedCode.Error;
        }

        var applied = SupplierProfileRules.Apply(supplier, command.Profile);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        supplier.SetActive(command.IsActive);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            MasterDataTables.Supplier,
            supplier.Id,
            AuditAction.Update,
            new { supplier.Code, supplier.Name, supplier.Currency, supplier.IsApprovedFoodSupplier, supplier.IsActive });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return supplier.Id;
    }
}

// ==================================================================== certificates

/// <summary><c>POST /masterdata/suppliers/{id}/certificates</c> — the expiry drives the weekly scanner job (spec §15).</summary>
public sealed record AddSupplierCertificateCommand(
    uint SupplierId,
    string CertType,
    string? CertNumber,
    DateOnly? IssuedDate,
    DateOnly? ExpiryDate,
    long? AttachmentId) : ICommand<SupplierCertificateDto>;

public sealed class AddSupplierCertificateCommandValidator : AbstractValidator<AddSupplierCertificateCommand>
{
    public AddSupplierCertificateCommandValidator()
    {
        RuleFor(c => c.SupplierId).GreaterThan(0u);
        RuleFor(c => c.CertType).NotEmpty().MaximumLength(SupplierCertificate.CertTypeMaxLength);
        RuleFor(c => c.CertNumber).MaximumLength(80);
    }
}

public sealed class AddSupplierCertificateCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    ISupplierRepository suppliers,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<AddSupplierCertificateCommand, SupplierCertificateDto>
{
    public async Task<Result<SupplierCertificateDto>> HandleAsync(AddSupplierCertificateCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var supplier = await suppliers.GetAsync(command.SupplierId, cancellationToken).ConfigureAwait(false);
        if (supplier is null)
        {
            return MasterDataErrors.SupplierNotFound(command.SupplierId);
        }

        var created = SupplierCertificate.CreateChecked(
            tenantContext.TenantId,
            command.CertType,
            command.CertNumber,
            command.IssuedDate,
            command.ExpiryDate,
            command.AttachmentId);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var certificate = created.Value;
        supplier.AddCertificate(certificate);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.SupplierCertificate,
            certificate.Id,
            AuditAction.Create,
            new { supplier.Code, certificate.CertType, certificate.CertNumber, certificate.ExpiryDate });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        return new SupplierCertificateDto(
            certificate.Id,
            supplier.Id,
            certificate.CertType,
            certificate.CertNumber,
            certificate.IssuedDate,
            certificate.ExpiryDate,
            certificate.AttachmentId,
            certificate.IsExpiredOn(today));
    }
}
