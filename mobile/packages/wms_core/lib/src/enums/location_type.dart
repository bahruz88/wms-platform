import 'package:json_annotation/json_annotation.dart';

/// `master_location.location_type` (spec §8).
enum LocationType {
  @JsonValue('CENTRAL_WAREHOUSE')
  centralWarehouse('CENTRAL_WAREHOUSE', isVirtual: false),
  @JsonValue('SUB_LOCATION')
  subLocation('SUB_LOCATION', isVirtual: false),
  @JsonValue('SHELF')
  shelf('SHELF', isVirtual: false),
  @JsonValue('RESTAURANT')
  restaurant('RESTAURANT', isVirtual: false),
  @JsonValue('IN_TRANSIT')
  inTransit('IN_TRANSIT', isVirtual: true),
  @JsonValue('V_SUPPLIER')
  vSupplier('V_SUPPLIER', isVirtual: true),
  @JsonValue('V_WASTE')
  vWaste('V_WASTE', isVirtual: true),
  @JsonValue('V_SAMPLE')
  vSample('V_SAMPLE', isVirtual: true),
  @JsonValue('V_ADJUSTMENT')
  vAdjustment('V_ADJUSTMENT', isVirtual: true),

  /// Counter-party of the branch consumption document (ADR-012): the
  /// theoretical usage leaves `RESTAURANT` and lands here.
  @JsonValue('V_CONSUMPTION')
  vConsumption('V_CONSUMPTION', isVirtual: true);

  const LocationType(this.wire, {required this.isVirtual});

  final String wire;

  /// Virtual locations are counter-parties of the double-entry ledger and
  /// are never selectable as a physical stock location in the UI.
  final bool isVirtual;

  static LocationType fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
