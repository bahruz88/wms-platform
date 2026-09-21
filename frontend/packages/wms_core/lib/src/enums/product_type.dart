import 'package:json_annotation/json_annotation.dart';

/// `master_product_category.product_type` / `proc_requisition.product_type`.
enum ProductType {
  @JsonValue('FOOD')
  food('FOOD'),
  @JsonValue('NON_FOOD')
  nonFood('NON_FOOD');

  const ProductType(this.wire);

  final String wire;

  static ProductType fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
