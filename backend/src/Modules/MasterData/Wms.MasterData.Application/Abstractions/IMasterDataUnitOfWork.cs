using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Auditing;

namespace Wms.MasterData.Application.Abstractions;

public interface IUnitOfWorkTransaction : IAsyncDisposable
{
    Task CommitAsync(CancellationToken cancellationToken);

    Task RollbackAsync(CancellationToken cancellationToken);
}

/// <summary>
/// Module unit of work over <c>MasterDataDbContext</c>. Audit rows are written by the same SaveChanges as the
/// mutation itself (spec §14.1, §16), so a rolled back transaction leaves no orphan audit entry.
/// </summary>
public interface IMasterDataUnitOfWork
{
    IIntegrationEventOutbox Outbox { get; }

    IAuditTrail Audit { get; }

    Task<IUnitOfWorkTransaction> BeginTransactionAsync(CancellationToken cancellationToken);

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}

/// <summary>Table names used as <c>common_audit_log.entity_type</c> (spec §16).</summary>
public static class MasterDataTables
{
    public const string Product = "master_product";
    public const string ProductUom = "master_product_uom";
    public const string Category = "master_product_category";
    public const string Uom = "master_uom";
    public const string Supplier = "master_supplier";
    public const string SupplierCertificate = "master_supplier_certificate";
    public const string Location = "master_location";
    public const string CurrencyRate = "master_currency_rate";
    public const string ReasonCode = "master_reason_code";
}
