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

/// <summary><c>POST /masterdata/uoms</c>.</summary>
public sealed record CreateUomCommand(string Code, string Name, UomClass UomClass, byte? Decimals) : ICommand<UomDto>;

public sealed class CreateUomCommandValidator : AbstractValidator<CreateUomCommand>
{
    public CreateUomCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Z0-9_]{1,12}$").WithMessage("code must match ^[A-Z0-9_]{1,12}$.");
        RuleFor(c => c.Name).NotEmpty().MaximumLength(60);
        RuleFor(c => c.Decimals).InclusiveBetween((byte)0, (byte)4).When(c => c.Decimals is not null);
    }
}

public sealed class CreateUomCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IUomRepository uoms,
    ITenantContext tenantContext) : ICommandHandler<CreateUomCommand, UomDto>
{
    public async Task<Result<UomDto>> HandleAsync(CreateUomCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var code = command.Code.Trim().ToUpperInvariant();
        if (await uoms.CodeExistsAsync(code, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.UomCodeAlreadyExists(code);
        }

        var created = Uom.Create(tenantContext.TenantId, code, command.Name, command.UomClass, command.Decimals ?? Uom.DefaultDecimals);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var uom = created.Value;

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        uoms.Add(uom);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.Uom,
            uom.Id,
            AuditAction.Create,
            new { uom.Code, uom.Name, UomClass = uom.UomClass.ToString(), uom.Decimals });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new UomDto(uom.Id, uom.Code, uom.Name, uom.UomClass, uom.Decimals);
    }
}
