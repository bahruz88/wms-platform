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

/// <summary><c>POST /masterdata/categories</c>. <c>path</c> is computed server side (<c>/NON_FOOD/CHEMICAL</c>).</summary>
public sealed record CreateCategoryCommand(
    uint? ParentId,
    string Code,
    string Name,
    ProductType ProductType,
    IssueStrategy? DefaultIssueStrategy) : ICommand<CategoryDto>;

public sealed class CreateCategoryCommandValidator : AbstractValidator<CreateCategoryCommand>
{
    public CreateCategoryCommandValidator()
    {
        RuleFor(c => c.Code).NotEmpty().Matches("^[A-Z0-9_]{1,32}$")
            .WithMessage("code must match ^[A-Z0-9_]{1,32}$.");
        RuleFor(c => c.Name).NotEmpty().MaximumLength(ProductCategory.NameMaxLength);
    }
}

public sealed class CreateCategoryCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IProductCategoryRepository categories,
    ITenantContext tenantContext) : ICommandHandler<CreateCategoryCommand, CategoryDto>
{
    public async Task<Result<CategoryDto>> HandleAsync(CreateCategoryCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var code = command.Code.Trim().ToUpperInvariant();
        if (await categories.CodeExistsAsync(code, null, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.CategoryCodeAlreadyExists(code);
        }

        ProductCategory? parent = null;
        if (command.ParentId is { } parentId)
        {
            parent = await categories.GetAsync(parentId, cancellationToken).ConfigureAwait(false);
            if (parent is null)
            {
                return MasterDataErrors.CategoryNotFound(parentId);
            }

            if (parent.ProductType != command.ProductType)
            {
                return MasterDataErrors.InvalidCategory("A category must carry the same product_type as its parent.");
            }
        }

        var category = ProductCategory.Create(
            tenantContext.TenantId,
            code,
            command.Name,
            command.ProductType,
            parent?.Id,
            parent?.Path,
            command.DefaultIssueStrategy);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        categories.Add(category);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.Category,
            category.Id,
            AuditAction.Create,
            new { category.Code, category.Name, ProductType = category.ProductType.ToString(), category.Path });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return CategoryMapper.ToDto(category);
    }
}

// ==================================================================== update

/// <summary>
/// <c>PUT /masterdata/categories/{id}</c>. <see cref="ProductType"/> is accepted only to answer a precise
/// <c>422 PRODUCT_TYPE_IMMUTABLE</c> when a client tries to change it.
/// </summary>
public sealed record UpdateCategoryCommand(
    uint CategoryId,
    uint RowVersion,
    uint? ParentId,
    string Name,
    IssueStrategy? DefaultIssueStrategy,
    bool IsActive,
    ProductType? ProductType) : ICommand<CategoryDto>;

public sealed class UpdateCategoryCommandValidator : AbstractValidator<UpdateCategoryCommand>
{
    public UpdateCategoryCommandValidator()
    {
        RuleFor(c => c.CategoryId).GreaterThan(0u);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Name).NotEmpty().MaximumLength(ProductCategory.NameMaxLength);
    }
}

public sealed class UpdateCategoryCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IProductCategoryRepository categories,
    ITenantContext tenantContext) : ICommandHandler<UpdateCategoryCommand, CategoryDto>
{
    public async Task<Result<CategoryDto>> HandleAsync(UpdateCategoryCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var all = await categories.ListAsync(cancellationToken).ConfigureAwait(false);
        var category = all.FirstOrDefault(c => c.Id == command.CategoryId);
        if (category is null)
        {
            return MasterDataErrors.CategoryNotFound(command.CategoryId);
        }

        if (category.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        var productType = category.ChangeProductType(command.ProductType);
        if (productType.IsFailure)
        {
            return productType.Error;
        }

        var rename = category.Rename(command.Name);
        if (rename.IsFailure)
        {
            return rename.Error;
        }

        if (command.ParentId != category.ParentId)
        {
            var moved = MoveTo(category, command.ParentId, all);
            if (moved.IsFailure)
            {
                return moved.Error;
            }
        }

        category.SetDefaultIssueStrategy(command.DefaultIssueStrategy);
        category.SetActive(command.IsActive);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            MasterDataTables.Category,
            category.Id,
            AuditAction.Update,
            new { category.Code, category.Name, category.Path, category.IsActive });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return CategoryMapper.ToDto(category);
    }

    /// <summary>Re-parents the category and rewrites the materialised path of every descendant.</summary>
    private static Result MoveTo(ProductCategory category, uint? parentId, IReadOnlyList<ProductCategory> all)
    {
        ProductCategory? parent = null;
        if (parentId is { } newParentId)
        {
            parent = all.FirstOrDefault(c => c.Id == newParentId);
            if (parent is null)
            {
                return MasterDataErrors.CategoryNotFound(newParentId);
            }

            if (parent.ProductType != category.ProductType)
            {
                return MasterDataErrors.InvalidCategory("A category must carry the same product_type as its parent.");
            }

            if (parent.Id == category.Id || IsDescendant(parent, category, all))
            {
                return MasterDataErrors.CategoryCycle(category.Id);
            }
        }

        var moved = category.Reparent(parent?.Id, parent?.Path);
        if (moved.IsFailure)
        {
            return moved;
        }

        return RebuildDescendants(category, all);
    }

    private static bool IsDescendant(ProductCategory candidate, ProductCategory ancestor, IReadOnlyList<ProductCategory> all)
    {
        var current = candidate;
        var guard = 0;
        while (current?.ParentId is { } parentId && guard++ < all.Count)
        {
            if (parentId == ancestor.Id)
            {
                return true;
            }

            current = all.FirstOrDefault(c => c.Id == parentId);
        }

        return false;
    }

    private static Result RebuildDescendants(ProductCategory parent, IReadOnlyList<ProductCategory> all)
    {
        foreach (var child in all.Where(c => c.ParentId == parent.Id))
        {
            var rebuilt = child.RebuildPath(parent.Path);
            if (rebuilt.IsFailure)
            {
                return rebuilt;
            }

            var nested = RebuildDescendants(child, all);
            if (nested.IsFailure)
            {
                return nested;
            }
        }

        return Result.Success();
    }
}

internal static class CategoryMapper
{
    public static CategoryDto ToDto(ProductCategory category) => new(
        category.Id,
        category.ParentId,
        category.Code,
        category.Name,
        category.ProductType,
        category.Path,
        category.DefaultIssueStrategy,
        category.IsActive,
        category.RowVersion);
}
