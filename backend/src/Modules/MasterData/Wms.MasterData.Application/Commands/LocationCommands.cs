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

// ==================================================================== create

/// <summary><c>POST /masterdata/locations</c>. A second virtual location of the same type is refused (spec §12.3).</summary>
public sealed record CreateLocationCommand(
    uint? ParentId,
    string Code,
    string Name,
    LocationType LocationType,
    bool AllowsFood,
    bool AllowsNonFood) : ICommand<LocationDetailDto>;

public sealed class CreateLocationCommandValidator : AbstractValidator<CreateLocationCommand>
{
    public CreateLocationCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$")
            .WithMessage("code must match ^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$.");
        RuleFor(c => c.Name).NotEmpty().MaximumLength(Location.NameMaxLength);
    }
}

public sealed class CreateLocationCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    ILocationRepository locations,
    ITenantContext tenantContext) : ICommandHandler<CreateLocationCommand, LocationDetailDto>
{
    public async Task<Result<LocationDetailDto>> HandleAsync(CreateLocationCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var code = Location.NormalizeCode(command.Code);
        if (await locations.CodeExistsAsync(code, null, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.LocationCodeAlreadyExists(code);
        }

        if (Location.IsVirtualType(command.LocationType)
            && await locations.VirtualTypeExistsAsync(command.LocationType, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.VirtualLocationExists(command.LocationType.ToString());
        }

        if (command.ParentId is { } parentId
            && await locations.GetAsync(parentId, cancellationToken).ConfigureAwait(false) is null)
        {
            return MasterDataErrors.LocationNotFound(parentId);
        }

        var created = Location.Create(
            tenantContext.TenantId,
            code,
            command.Name,
            command.LocationType,
            command.ParentId,
            command.AllowsFood,
            command.AllowsNonFood);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var location = created.Value;

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        locations.Add(location);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.Location,
            location.Id,
            AuditAction.Create,
            new { location.Code, location.Name, LocationType = location.LocationType.ToString(), location.IsVirtual });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return LocationMapper.ToDto(location);
    }
}

// ==================================================================== update

/// <summary>
/// <c>PUT /masterdata/locations/{id}</c>. <see cref="LocationType"/> is accepted only to answer a precise
/// <c>422 LOCATION_TYPE_IMMUTABLE</c>; <c>isVirtual</c> is derived from it and therefore equally frozen.
/// </summary>
public sealed record UpdateLocationCommand(
    uint LocationId,
    uint RowVersion,
    uint? ParentId,
    string Name,
    bool AllowsFood,
    bool AllowsNonFood,
    bool IsActive,
    LocationType? LocationType) : ICommand<LocationDetailDto>;

public sealed class UpdateLocationCommandValidator : AbstractValidator<UpdateLocationCommand>
{
    public UpdateLocationCommandValidator()
    {
        RuleFor(c => c.LocationId).GreaterThan(0u);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Name).NotEmpty().MaximumLength(Location.NameMaxLength);
    }
}

public sealed class UpdateLocationCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    ILocationRepository locations,
    ITenantContext tenantContext) : ICommandHandler<UpdateLocationCommand, LocationDetailDto>
{
    public async Task<Result<LocationDetailDto>> HandleAsync(UpdateLocationCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var location = await locations.GetAsync(command.LocationId, cancellationToken).ConfigureAwait(false);
        if (location is null)
        {
            return MasterDataErrors.LocationNotFound(command.LocationId);
        }

        if (location.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var locationType = location.ChangeLocationType(command.LocationType);
        if (locationType.IsFailure)
        {
            return locationType.Error;
        }

        if (command.ParentId != location.ParentId
            && command.ParentId is { } parentId
            && await locations.GetAsync(parentId, cancellationToken).ConfigureAwait(false) is null)
        {
            return MasterDataErrors.LocationNotFound(parentId);
        }

        var renamed = location.Rename(command.Name);
        if (renamed.IsFailure)
        {
            return renamed.Error;
        }

        var reparented = location.Reparent(command.ParentId);
        if (reparented.IsFailure)
        {
            return reparented.Error;
        }

        location.SetStorageRules(command.AllowsFood, command.AllowsNonFood);
        location.SetActive(command.IsActive);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            MasterDataTables.Location,
            location.Id,
            AuditAction.Update,
            new { location.Code, location.Name, location.AllowsFood, location.AllowsNonFood, location.IsActive });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return LocationMapper.ToDto(location);
    }
}

internal static class LocationMapper
{
    public static LocationDetailDto ToDto(Location location) => new(
        location.Id,
        location.ParentId,
        location.Code,
        location.Name,
        location.LocationType,
        location.IsVirtual,
        location.AllowsFood,
        location.AllowsNonFood,
        location.IsActive,
        location.RowVersion);
}
