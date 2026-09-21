using Wms.Common.Domain;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_supplier</c> (spec §8).</summary>
public sealed class Supplier : AuditableAggregateRoot<uint>, ITenantEntity, ISoftDeletable
{
    private readonly List<SupplierCertificate> _certificates = [];

    private Supplier()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    /// <summary>VÖEN.</summary>
    public string? TaxId { get; private set; }

    public string? ContactPerson { get; private set; }

    public string? Phone { get; private set; }

    public string? Email { get; private set; }

    public string? Address { get; private set; }

    public string? BankDetails { get; private set; }

    public string Currency { get; private set; } = "AZN";

    public string? PaymentTerms { get; private set; }

    public string? DeliveryTerms { get; private set; }

    public string? Incoterms { get; private set; }

    /// <summary>TOR §7: food may only be purchased from approved suppliers.</summary>
    public bool IsApprovedFoodSupplier { get; private set; }

    public bool IsActive { get; private set; } = true;

    public bool IsDeleted { get; private set; }

    public IReadOnlyList<SupplierCertificate> Certificates => _certificates.AsReadOnly();

    public static Result<Supplier> Create(uint tenantId, string code, string name, string currency = "AZN", string? taxId = null)
    {
        var normalizedCode = (code ?? string.Empty).Trim().ToUpperInvariant();
        var normalizedName = (name ?? string.Empty).Trim();
        if (normalizedCode.Length is 0 or > 32)
        {
            return MasterDataErrors.InvalidSupplier("code must be 1..32 characters.");
        }

        if (normalizedName.Length is 0 or > 250)
        {
            return MasterDataErrors.InvalidSupplier("name must be 1..250 characters.");
        }

        if (!Money.IsValidCurrency(currency))
        {
            return MasterDataErrors.InvalidSupplier("currency must be an ISO 4217 code.");
        }

        return new Supplier
        {
            TenantId = tenantId,
            Code = normalizedCode,
            Name = normalizedName,
            Currency = currency.ToUpperInvariant(),
            TaxId = taxId?.Trim(),
        };
    }

    public void ApproveAsFoodSupplier() => IsApprovedFoodSupplier = true;

    public void RevokeFoodApproval() => IsApprovedFoodSupplier = false;

    public void AddCertificate(SupplierCertificate certificate)
    {
        ArgumentNullException.ThrowIfNull(certificate);
        _certificates.Add(certificate);
    }

    public void SoftDelete()
    {
        IsDeleted = true;
        IsActive = false;
    }

    public void Restore() => IsDeleted = false;
}

/// <summary><c>master_supplier_certificate</c> — expiry drives the weekly CertificateExpiryScanner job (spec §15).</summary>
public sealed class SupplierCertificate : Entity<uint>, ITenantEntity
{
    private SupplierCertificate()
    {
    }

    public uint TenantId { get; private set; }

    public uint SupplierId { get; private set; }

    public string CertType { get; private set; } = string.Empty;

    public string? CertNumber { get; private set; }

    public DateOnly? IssuedDate { get; private set; }

    public DateOnly? ExpiryDate { get; private set; }

    public long? AttachmentId { get; private set; }

    public static SupplierCertificate Create(uint tenantId, string certType, string? certNumber, DateOnly? issuedDate, DateOnly? expiryDate, long? attachmentId = null)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(certType);
        return new SupplierCertificate
        {
            TenantId = tenantId,
            CertType = certType.Trim(),
            CertNumber = certNumber?.Trim(),
            IssuedDate = issuedDate,
            ExpiryDate = expiryDate,
            AttachmentId = attachmentId,
        };
    }
}
