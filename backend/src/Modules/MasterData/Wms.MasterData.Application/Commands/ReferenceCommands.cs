using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;
using Wms.Common.Application.Messaging;
using Wms.Common.Domain;
using Wms.MasterData.Application.Abstractions;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Domain;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Application.Commands;

// ==================================================================== currency rates

/// <summary>
/// <c>POST /masterdata/currency-rates</c>. An existing <c>(currency, rateDate)</c> row is re-rated and switches to
/// <c>MANUAL</c>; there is no fallback to an older date anywhere (spec §12.5).
/// </summary>
public sealed record UpsertCurrencyRateCommand(string Currency, DateOnly RateDate, decimal RateToBase) : ICommand<CurrencyRateDto>;

public sealed class UpsertCurrencyRateCommandValidator : AbstractValidator<UpsertCurrencyRateCommand>
{
    public UpsertCurrencyRateCommandValidator()
    {
        RuleFor(c => c.Currency).NotEmpty().Matches("^[A-Z]{3}$").WithMessage("currency must be an ISO 4217 code.");
        RuleFor(c => c.RateDate).NotEqual(default(DateOnly));
        RuleFor(c => c.RateToBase).GreaterThan(0m);
    }
}

public sealed class UpsertCurrencyRateCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    ICurrencyRateRepository rates,
    ITenantContext tenantContext) : ICommandHandler<UpsertCurrencyRateCommand, CurrencyRateDto>
{
    public async Task<Result<CurrencyRateDto>> HandleAsync(UpsertCurrencyRateCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var currency = command.Currency.Trim().ToUpperInvariant();

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var existing = await rates.FindAsync(currency, command.RateDate, cancellationToken).ConfigureAwait(false);
        CurrencyRate rate;
        AuditAction action;
        if (existing is null)
        {
            var created = CurrencyRate.Create(tenantContext.TenantId, currency, command.RateDate, command.RateToBase, CurrencyRate.ManualSource);
            if (created.IsFailure)
            {
                return created.Error;
            }

            rate = created.Value;
            rates.Add(rate);
            action = AuditAction.Create;
        }
        else
        {
            var previous = existing.RateToBase;
            var updated = existing.UpdateRate(command.RateToBase, CurrencyRate.ManualSource);
            if (updated.IsFailure)
            {
                return updated.Error;
            }

            rate = existing;
            action = AuditAction.Update;
            unitOfWork.Audit.Record(
                MasterDataTables.CurrencyRate,
                rate.Id,
                action,
                new { rate.Currency, rate.RateDate, previousRateToBase = previous, rate.RateToBase, rate.Source });
        }

        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        if (action == AuditAction.Create)
        {
            unitOfWork.Audit.Record(
                MasterDataTables.CurrencyRate,
                rate.Id,
                action,
                new { rate.Currency, rate.RateDate, rate.RateToBase, rate.Source });
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }

        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new CurrencyRateDto(rate.Id, rate.Currency, rate.RateDate, rate.RateToBase, rate.Source);
    }
}

// ==================================================================== reason codes

/// <summary><c>POST /masterdata/reason-codes</c>.</summary>
public sealed record CreateReasonCodeCommand(
    string Code,
    string Name,
    ReasonGroup ReasonGroup,
    bool RequiresApproval,
    bool RequiresPhoto) : ICommand<ReasonCodeDto>;

public sealed class CreateReasonCodeCommandValidator : AbstractValidator<CreateReasonCodeCommand>
{
    public CreateReasonCodeCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Z0-9_]{1,32}$").WithMessage("code must match ^[A-Z0-9_]{1,32}$.");
        RuleFor(c => c.Name).NotEmpty().MaximumLength(ReasonCode.NameMaxLength);
    }
}

public sealed class CreateReasonCodeCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IReasonCodeRepository reasonCodes,
    ITenantContext tenantContext) : ICommandHandler<CreateReasonCodeCommand, ReasonCodeDto>
{
    public async Task<Result<ReasonCodeDto>> HandleAsync(CreateReasonCodeCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var code = ReasonCode.NormalizeCode(command.Code);
        if (await reasonCodes.CodeExistsAsync(code, null, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.ReasonCodeAlreadyExists(code);
        }

        var reasonCode = ReasonCode.Create(
            tenantContext.TenantId,
            code,
            command.Name,
            command.ReasonGroup,
            command.RequiresApproval,
            command.RequiresPhoto);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        reasonCodes.Add(reasonCode);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.ReasonCode,
            reasonCode.Id,
            AuditAction.Create,
            new { reasonCode.Code, reasonCode.Name, ReasonGroup = reasonCode.ReasonGroup.ToString(), reasonCode.RequiresApproval, reasonCode.RequiresPhoto });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return ReasonCodeMapper.ToDto(reasonCode);
    }
}

/// <summary>
/// <c>PUT /masterdata/reason-codes/{id}</c>. <see cref="ReasonGroup"/> is accepted only to answer a precise
/// <c>422 REASON_GROUP_IMMUTABLE</c> when a client tries to move the code between screens.
/// </summary>
public sealed record UpdateReasonCodeCommand(
    ushort ReasonCodeId,
    uint RowVersion,
    string Name,
    bool RequiresApproval,
    bool RequiresPhoto,
    bool IsActive,
    ReasonGroup? ReasonGroup) : ICommand<ReasonCodeDto>;

public sealed class UpdateReasonCodeCommandValidator : AbstractValidator<UpdateReasonCodeCommand>
{
    public UpdateReasonCodeCommandValidator()
    {
        RuleFor(c => c.ReasonCodeId).GreaterThan((ushort)0);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Name).NotEmpty().MaximumLength(ReasonCode.NameMaxLength);
    }
}

public sealed class UpdateReasonCodeCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IReasonCodeRepository reasonCodes,
    ITenantContext tenantContext) : ICommandHandler<UpdateReasonCodeCommand, ReasonCodeDto>
{
    public async Task<Result<ReasonCodeDto>> HandleAsync(UpdateReasonCodeCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var reasonCode = await reasonCodes.GetAsync(command.ReasonCodeId, cancellationToken).ConfigureAwait(false);
        if (reasonCode is null)
        {
            return MasterDataErrors.ReasonCodeNotFound(command.ReasonCodeId);
        }

        if (reasonCode.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var group = reasonCode.ChangeReasonGroup(command.ReasonGroup);
        if (group.IsFailure)
        {
            return group.Error;
        }

        var renamed = reasonCode.Rename(command.Name);
        if (renamed.IsFailure)
        {
            return renamed.Error;
        }

        reasonCode.SetApprovalRules(command.RequiresApproval, command.RequiresPhoto);
        reasonCode.SetActive(command.IsActive);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            MasterDataTables.ReasonCode,
            reasonCode.Id,
            AuditAction.Update,
            new { reasonCode.Code, reasonCode.Name, reasonCode.RequiresApproval, reasonCode.RequiresPhoto, reasonCode.IsActive });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return ReasonCodeMapper.ToDto(reasonCode);
    }
}

internal static class ReasonCodeMapper
{
    public static ReasonCodeDto ToDto(ReasonCode reasonCode) => new(
        reasonCode.Id,
        reasonCode.Code,
        reasonCode.Name,
        reasonCode.ReasonGroup,
        reasonCode.RequiresApproval,
        reasonCode.RequiresPhoto,
        reasonCode.IsActive,
        reasonCode.RowVersion);
}
