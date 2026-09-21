using Wms.Common.Domain;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_supplier</c> (spec §8).</summary>
public sealed class Supplier : AuditableAggregateRoot<uint>, ITenantEntity, ISoftDeletable
{
    public const int CodeMaxLength = 32;
    public const int NameMaxLength = 250;

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
        var normalizedCode = NormalizeCode(code);
        var normalizedName = (name ?? string.Empty).Trim();
        if (normalizedCode.Length is 0 or > CodeMaxLength)
        {
            return MasterDataErrors.InvalidSupplier("code must be 1..32 characters.");
        }

        if (normalizedName.Length is 0 or > NameMaxLength)
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

    public static string NormalizeCode(string? code) => (code ?? string.Empty).Trim().ToUpperInvariant();

    public Result Rename(string name)
    {
        var normalized = (name ?? string.Empty).Trim();
        if (normalized.Length is 0 or > NameMaxLength)
        {
            return MasterDataErrors.InvalidSupplier("name must be 1..250 characters.");
        }

        Name = normalized;
        return Result.Success();
    }

    public Result ChangeCode(string code)
    {
        var normalized = NormalizeCode(code);
        if (normalized.Length is 0 or > CodeMaxLength)
        {
            return MasterDataErrors.InvalidSupplier("code must be 1..32 characters.");
        }

        Code = normalized;
        return Result.Success();
    }

    public Result ChangeCurrency(string currency)
    {
        if (!Money.IsValidCurrency(currency))
        {
            return MasterDataErrors.InvalidSupplier("currency must be an ISO 4217 code.");
        }

        Currency = currency.ToUpperInvariant();
        return Result.Success();
    }

    public void SetContactDetails(string? contactPerson, string? phone, string? email, string? address)
    {
        ContactPerson = Trim(contactPerson);
        Phone = Trim(phone);
        Email = Trim(email);
        Address = Trim(address);
    }

    public void SetCommercialTerms(string? bankDetails, string? paymentTerms, string? deliveryTerms, string? incoterms)
    {
        BankDetails = Trim(bankDetails);
        PaymentTerms = Trim(paymentTerms);
        DeliveryTerms = Trim(deliveryTerms);
        Incoterms = Trim(incoterms);
    }

    public void SetTaxId(string? taxId) => TaxId = Trim(taxId);

    public void SetFoodApproval(bool approved) => IsApprovedFoodSupplier = approved;

    public void SetActive(bool isActive) => IsActive = isActive;

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

    private static string? Trim(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}

/// <summary><c>master_supplier_certificate</c> — expiry drives the weekly CertificateExpiryScanner job (spec §15).</summary>
public sealed class SupplierCertificate : Entity<uint>, ITenantEntity
{
    public const int CertTypeMaxLength = 80;

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

    /// <summary>Validating factory used by the API; the plain one stays for seeding and tests.</summary>
    public static Result<SupplierCertificate> CreateChecked(uint tenantId, string? certType, string? certNumber, DateOnly? issuedDate, DateOnly? expiryDate, long? attachmentId)
    {
        var normalized = (certType ?? string.Empty).Trim();
        if (normalized.Length is 0 or > CertTypeMaxLength)
        {
            return MasterDataErrors.InvalidCertificate("cert_type must be 1..80 characters.");
        }

        if (issuedDate is { } issued && expiryDate is { } expiry && expiry < issued)
        {
            return MasterDataErrors.InvalidCertificate("expiry_date cannot be earlier than issued_date.");
        }

        return Create(tenantId, normalized, certNumber, issuedDate, expiryDate, attachmentId);
    }

    public bool IsExpiredOn(DateOnly date) => ExpiryDate is { } expiry && expiry < date;
}
