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

/// <summary>One line of <c>ProductCreate.additionalUoms</c> / the body of <c>addProductUom</c>.</summary>
public sealed record ProductUomInput(ushort UomId, decimal FactorToBase, bool IsPurchaseDefault, bool IsIssueDefault, DateOnly ValidFrom);

// ==================================================================== create

/// <summary><c>POST /masterdata/products</c>. The base UoM row (factor 1) is created automatically (spec §8).</summary>
public sealed record CreateProductCommand(
    string Sku,
    string Name,
    string? Barcode,
    uint CategoryId,
    string? Brand,
    ushort BaseUomId,
    uint? DefaultSupplierId,
    decimal? MinStock,
    decimal? MaxStock,
    decimal? ReorderPoint,
    decimal? VatRate,
    bool RequiresBatch,
    bool RequiresExpiry,
    IssueStrategy? IssueStrategy,
    ushort? ShelfLifeDays,
    IReadOnlyList<ProductUomInput> AdditionalUoms) : ICommand<uint>;

public sealed class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(c => c.Sku).NotEmpty().MaximumLength(Product.SkuMaxLength)
            .Matches("^[A-Za-z0-9][A-Za-z0-9._-]{0,47}$").WithMessage("sku must match ^[A-Za-z0-9][A-Za-z0-9._-]{0,47}$.");
        RuleFor(c => c.Name).NotEmpty().MaximumLength(Product.NameMaxLength);
        RuleFor(c => c.Barcode).MaximumLength(Product.BarcodeMaxLength);
        RuleFor(c => c.Brand).MaximumLength(Product.BrandMaxLength);
        RuleFor(c => c.CategoryId).GreaterThan(0u);
        RuleFor(c => c.BaseUomId).GreaterThan((ushort)0);
        RuleFor(c => c.VatRate).InclusiveBetween(0m, 100m).When(c => c.VatRate is not null);
        RuleForEach(c => c.AdditionalUoms).ChildRules(uom =>
        {
            uom.RuleFor(u => u.UomId).GreaterThan((ushort)0);
            uom.RuleFor(u => u.FactorToBase).GreaterThan(0m);
            uom.RuleFor(u => u.ValidFrom).NotEqual(default(DateOnly));
        });
    }
}

public sealed class CreateProductCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IProductRepository products,
    IProductCategoryRepository categories,
    IUomRepository uoms,
    ISupplierRepository suppliers,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<CreateProductCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(CreateProductCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var sku = Product.NormalizeSku(command.Sku);
        if (await products.SkuExistsAsync(sku, null, cancellationToken).ConfigureAwait(false))
        {
            return MasterDataErrors.SkuAlreadyExists(sku);
        }

        var category = await categories.GetAsync(command.CategoryId, cancellationToken).ConfigureAwait(false);
        if (category is null)
        {
            return MasterDataErrors.CategoryNotFound(command.CategoryId);
        }

        var baseUom = await uoms.GetAsync(command.BaseUomId, cancellationToken).ConfigureAwait(false);
        if (baseUom is null)
        {
            return MasterDataErrors.UomNotFound(command.BaseUomId);
        }

        if (command.DefaultSupplierId is { } supplierId
            && await suppliers.GetAsync(supplierId, cancellationToken).ConfigureAwait(false) is null)
        {
            return MasterDataErrors.SupplierNotFound(supplierId);
        }

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var created = Product.Create(
            tenantContext.TenantId,
            sku,
            command.Name,
            command.CategoryId,
            command.BaseUomId,
            today,
            command.RequiresBatch,
            command.RequiresExpiry,
            command.IssueStrategy ?? category.DefaultIssueStrategy ?? Domain.Enums.IssueStrategy.Fefo,
            command.VatRate ?? Product.DefaultVatRate);
        if (created.IsFailure)
        {
            return created.Error;
        }

        var product = created.Value;
        product.SetBarcode(command.Barcode);
        product.SetBrand(command.Brand);
        product.SetDefaultSupplier(command.DefaultSupplierId);
        product.SetStockLevels(command.MinStock, command.MaxStock, command.ReorderPoint);
        product.SetShelfLife(command.ShelfLifeDays);

        foreach (var additional in command.AdditionalUoms)
        {
            if (await uoms.GetAsync(additional.UomId, cancellationToken).ConfigureAwait(false) is null)
            {
                return MasterDataErrors.UomNotFound(additional.UomId);
            }

            var added = product.AddOrReplaceUom(
                additional.UomId,
                additional.FactorToBase,
                additional.ValidFrom == default ? today : additional.ValidFrom,
                additional.IsPurchaseDefault,
                additional.IsIssueDefault);
            if (added.IsFailure)
            {
                return added.Error;
            }
        }

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        products.Add(product);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.Product,
            product.Id,
            AuditAction.Create,
            new { product.Sku, product.Name, product.CategoryId, product.BaseUomId, uoms = product.Uoms.Count });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return product.Id;
    }
}

// ==================================================================== update

/// <summary>
/// <c>PUT /masterdata/products/{id}</c>. <see cref="Sku"/> and <see cref="BaseUomId"/> are accepted only so a client
/// that sends them unchanged succeeds and one that tries to change them gets a precise <c>422</c> (spec §12.1).
/// </summary>
public sealed record UpdateProductCommand(
    uint ProductId,
    uint RowVersion,
    string Name,
    string? Barcode,
    uint CategoryId,
    string? Brand,
    uint? DefaultSupplierId,
    decimal? MinStock,
    decimal? MaxStock,
    decimal? ReorderPoint,
    decimal VatRate,
    bool RequiresBatch,
    bool RequiresExpiry,
    IssueStrategy IssueStrategy,
    ushort? ShelfLifeDays,
    long? ImageAttachmentId,
    bool IsActive,
    string? Sku,
    ushort? BaseUomId) : ICommand<uint>;

public sealed class UpdateProductCommandValidator : AbstractValidator<UpdateProductCommand>
{
    public UpdateProductCommandValidator()
    {
        RuleFor(c => c.ProductId).GreaterThan(0u);
        RuleFor(c => c.RowVersion).GreaterThan(0u);
        RuleFor(c => c.Name).NotEmpty().MaximumLength(Product.NameMaxLength);
        RuleFor(c => c.Barcode).MaximumLength(Product.BarcodeMaxLength);
        RuleFor(c => c.Brand).MaximumLength(Product.BrandMaxLength);
        RuleFor(c => c.CategoryId).GreaterThan(0u);
        RuleFor(c => c.VatRate).InclusiveBetween(0m, 100m);
    }
}

public sealed class UpdateProductCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IProductRepository products,
    IProductCategoryRepository categories,
    ISupplierRepository suppliers,
    ITenantContext tenantContext) : ICommandHandler<UpdateProductCommand, uint>
{
    public async Task<Result<uint>> HandleAsync(UpdateProductCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var product = await products.GetAsync(command.ProductId, cancellationToken).ConfigureAwait(false);
        if (product is null)
        {
            return MasterDataErrors.ProductNotFound(command.ProductId);
        }

        if (product.RowVersion != command.RowVersion)
        {
            return CommonErrors.StaleVersion();
        }

        // Spec §12.1: refuse the frozen columns before anything else changes.
        var sku = product.ChangeSku(command.Sku);
        if (sku.IsFailure)
        {
            return sku.Error;
        }

        var baseUom = product.ChangeBaseUom(command.BaseUomId);
        if (baseUom.IsFailure)
        {
            return baseUom.Error;
        }

        if (command.CategoryId != product.CategoryId
            && await categories.GetAsync(command.CategoryId, cancellationToken).ConfigureAwait(false) is null)
        {
            return MasterDataErrors.CategoryNotFound(command.CategoryId);
        }

        if (command.DefaultSupplierId is { } supplierId
            && supplierId != product.DefaultSupplierId
            && await suppliers.GetAsync(supplierId, cancellationToken).ConfigureAwait(false) is null)
        {
            return MasterDataErrors.SupplierNotFound(supplierId);
        }

        var rename = product.Rename(command.Name);
        if (rename.IsFailure)
        {
            return rename.Error;
        }

        var category = product.SetCategory(command.CategoryId);
        if (category.IsFailure)
        {
            return category.Error;
        }

        var vat = product.SetVatRate(command.VatRate);
        if (vat.IsFailure)
        {
            return vat.Error;
        }

        product.SetBarcode(command.Barcode);
        product.SetBrand(command.Brand);
        product.SetDefaultSupplier(command.DefaultSupplierId);
        product.SetStockLevels(command.MinStock, command.MaxStock, command.ReorderPoint);
        product.SetTraceability(command.RequiresBatch, command.RequiresExpiry);
        product.SetIssueStrategy(command.IssueStrategy);
        product.SetShelfLife(command.ShelfLifeDays);
        product.SetImageAttachment(command.ImageAttachmentId);
        product.SetActive(command.IsActive);

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        unitOfWork.Audit.Record(
            MasterDataTables.Product,
            product.Id,
            AuditAction.Update,
            new { product.Sku, product.Name, product.CategoryId, product.VatRate, product.IsActive });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return product.Id;
    }
}

// ==================================================================== add / re-version a UoM

/// <summary>
/// <c>POST /masterdata/products/{id}/uoms</c>. Spec §12.1: an existing factor is never UPDATEd — the open row is
/// closed with <c>valid_to = validFrom − 1</c> and a new row opens, so frozen ledger conversion rates stay correct.
/// </summary>
public sealed record AddProductUomCommand(
    uint ProductId,
    ushort UomId,
    decimal FactorToBase,
    bool IsPurchaseDefault,
    bool IsIssueDefault,
    DateOnly ValidFrom) : ICommand<ProductUomDto>;

public sealed class AddProductUomCommandValidator : AbstractValidator<AddProductUomCommand>
{
    public AddProductUomCommandValidator()
    {
        RuleFor(c => c.ProductId).GreaterThan(0u);
        RuleFor(c => c.UomId).GreaterThan((ushort)0);
        RuleFor(c => c.FactorToBase).GreaterThan(0m);
        RuleFor(c => c.ValidFrom).NotEqual(default(DateOnly));
    }
}

public sealed class AddProductUomCommandHandler(
    IMasterDataUnitOfWork unitOfWork,
    IProductRepository products,
    IUomRepository uoms,
    ITenantContext tenantContext,
    IClock clock) : ICommandHandler<AddProductUomCommand, ProductUomDto>
{
    public async Task<Result<ProductUomDto>> HandleAsync(AddProductUomCommand command, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        if (!tenantContext.HasTenant)
        {
            return CommonErrors.TenantRequired();
        }

        var product = await products.GetAsync(command.ProductId, cancellationToken).ConfigureAwait(false);
        if (product is null)
        {
            return MasterDataErrors.ProductNotFound(command.ProductId);
        }

        var uom = await uoms.GetAsync(command.UomId, cancellationToken).ConfigureAwait(false);
        if (uom is null)
        {
            return MasterDataErrors.UomNotFound(command.UomId);
        }

        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        if (command.ValidFrom < today)
        {
            return MasterDataErrors.InvalidFactor("valid_from cannot be in the past: posted movements already froze the old factor.");
        }

        var applied = product.AddOrReplaceUom(
            command.UomId,
            command.FactorToBase,
            command.ValidFrom,
            command.IsPurchaseDefault,
            command.IsIssueDefault);
        if (applied.IsFailure)
        {
            return applied.Error;
        }

        var row = applied.Value;

        await using var transaction = await unitOfWork.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        unitOfWork.Audit.Record(
            MasterDataTables.ProductUom,
            row.Id,
            AuditAction.Create,
            new { product.Sku, row.UomId, row.FactorToBase, row.ValidFrom });
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        return new ProductUomDto(
            row.Id,
            product.Id,
            row.UomId,
            uom.Code,
            row.FactorToBase,
            row.IsPurchaseDefault,
            row.IsIssueDefault,
            row.ValidFrom,
            row.ValidTo);
    }
}
