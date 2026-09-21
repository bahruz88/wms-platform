import 'package:meta/meta.dart';

/// Tenant scope of the current session. The tenant id comes exclusively from
/// the JWT `tenant_id` claim (spec §12.9) and is never sent in a body/query.
@immutable
class TenantContext {
  const TenantContext({
    required this.tenantId,
    this.tenantCode,
    this.currency = 'AZN',
    this.timezone = 'Asia/Baku',
    this.locale = 'az-AZ',
  });

  /// Builds the context from decoded JWT claims. Returns `null` when the
  /// mandatory `tenant_id` claim is absent.
  static TenantContext? fromClaims(Map<String, Object?> claims) {
    final raw = claims['tenant_id'];
    final id = raw is int ? raw : int.tryParse('$raw');
    if (id == null) return null;
    return TenantContext(
      tenantId: id,
      tenantCode: claims['tenant_code'] as String?,
      currency: claims['tenant_currency'] as String? ?? 'AZN',
      timezone: claims['tenant_timezone'] as String? ?? 'Asia/Baku',
      locale: claims['tenant_locale'] as String? ?? 'az-AZ',
    );
  }

  final int tenantId;
  final String? tenantCode;

  /// Tenant base currency (ISO 4217).
  final String currency;
  final String timezone;
  final String locale;

  @override
  bool operator ==(Object other) =>
      other is TenantContext &&
      other.tenantId == tenantId &&
      other.tenantCode == tenantCode &&
      other.currency == currency &&
      other.timezone == timezone &&
      other.locale == locale;

  @override
  int get hashCode =>
      Object.hash(tenantId, tenantCode, currency, timezone, locale);

  @override
  String toString() => 'TenantContext($tenantId, $currency)';
}
