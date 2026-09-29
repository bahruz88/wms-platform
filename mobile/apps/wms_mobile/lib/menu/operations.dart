import 'package:feature_consumption/feature_consumption.dart';
import 'package:feature_inventory/feature_inventory.dart';
import 'package:feature_procurement/feature_procurement.dart';
import 'package:flutter/material.dart';
import 'package:wms_core/wms_core.dart';

import 'operation.dart';

/// Everything the mobile app can do, with the permission that unlocks each.
///
/// One catalogue, not one per role: which tiles appear is decided by the
/// permissions the person actually holds, so the keeper's menu, the branch's
/// menu and the buyer's menu fall out of it without any of the three being
/// written down separately.
const List<WmsOperation> kOperations = [
  // ---------------------------------------------------------------- inbound
  WmsOperation(
    label: 'Mal qəbul et',
    hint: 'Təchizatçıdan gələn mal',
    icon: Icons.local_shipping_outlined,
    route: InventoryRoutes.receiptCreateFullPath,
    permission: Permissions.receiptCreate,
    group: WmsOperationGroup.inbound,
  ),
  WmsOperation(
    label: 'Gələni təsdiqlə',
    hint: 'Anbardan filiala göndəriş',
    icon: Icons.move_to_inbox_outlined,
    route: InventoryRoutes.issuesPath,
    permission: Permissions.issueConfirm,
    group: WmsOperationGroup.inbound,
  ),

  // --------------------------------------------------------------- outbound
  WmsOperation(
    label: 'Göndərişlər',
    hint: 'Yığım və yola salma',
    icon: Icons.outbox_outlined,
    route: InventoryRoutes.issuesPath,
    permission: Permissions.issueCreate,
    group: WmsOperationGroup.outbound,
  ),
  WmsOperation(
    label: 'Mal istə',
    hint: 'Anbardan tələb',
    icon: Icons.playlist_add_outlined,
    route: InventoryRoutes.stockRequestCreatePath,
    permission: Permissions.stockRequestCreate,
    group: WmsOperationGroup.outbound,
  ),

  // ---------------------------------------------------------------- control
  WmsOperation(
    label: 'Sayım',
    icon: Icons.fact_check_outlined,
    route: InventoryRoutes.countsPath,
    permission: Permissions.countEnter,
    group: WmsOperationGroup.control,
  ),
  WmsOperation(
    label: 'Tullantı',
    icon: Icons.delete_outline,
    route: InventoryRoutes.wasteCreateFullPath,
    permission: Permissions.wasteCreate,
    group: WmsOperationGroup.control,
  ),
  WmsOperation(
    label: 'Nümunə',
    hint: 'AQTA üçün',
    icon: Icons.science_outlined,
    route: InventoryRoutes.sampleCreateFullPath,
    permission: Permissions.sampleCreate,
    group: WmsOperationGroup.control,
  ),

  // ----------------------------------------------------------------- branch
  WmsOperation(
    label: 'Günün satışı',
    hint: 'Kassa hesabından',
    icon: Icons.point_of_sale_outlined,
    route: ConsumptionRoutes.dailySalesPath,
    permission: Permissions.salesImport,
    group: WmsOperationGroup.branch,
  ),
  WmsOperation(
    label: 'İstehlak nəticəsi',
    hint: 'Dünənki hesablama',
    icon: Icons.insights_outlined,
    route: ConsumptionRoutes.resultPath,
    permission: Permissions.varianceView,
    group: WmsOperationGroup.branch,
  ),

  // ------------------------------------------------------------ procurement
  WmsOperation(
    label: 'Tələblər',
    hint: 'Filialdan gələn sifarişlər',
    icon: Icons.assignment_outlined,
    route: ProcurementRoutes.requisitionsPath,
    permission: Permissions.requisitionCreate,
    group: WmsOperationGroup.procurement,
  ),
  WmsOperation(
    label: 'Təklif sorğuları',
    hint: 'Təchizatçı qiymətləri',
    icon: Icons.request_quote_outlined,
    route: ProcurementRoutes.rfqsPath,
    permission: Permissions.rfqCreate,
    group: WmsOperationGroup.procurement,
  ),

  // ----------------------------------------------------------------- lookup
  WmsOperation(
    label: 'Qalıq',
    hint: 'Nə qədər var',
    icon: Icons.inventory_2_outlined,
    route: InventoryRoutes.balancesPath,
    permission: Permissions.balanceView,
    group: WmsOperationGroup.lookup,
  ),
  WmsOperation(
    label: 'Barkod oxu',
    icon: Icons.qr_code_scanner_outlined,
    route: InventoryRoutes.scanPath,
    permission: Permissions.balanceView,
    group: WmsOperationGroup.lookup,
  ),
];

/// The workplace a person is in, for the one line that names it.
///
/// Read from the roles, not from the permissions: a role is what someone *is*,
/// and it is the word they would use for themselves. The tiles below still come
/// from the permissions, so an unusual account — a keeper who also enters sales
/// — gets the tiles for both without the heading having to hedge.
enum WmsWorkplace {
  keeper('Anbar'),
  branch('Filial'),
  procurement('Satınalma'),
  administration('İdarəetmə'),
  unknown('');

  const WmsWorkplace(this.label);

  final String label;

  static WmsWorkplace fromRoles(List<String> roles) {
    if (roles.contains(Roles.warehouseKeeper)) return keeper;
    if (roles.contains(Roles.branchUser)) return branch;
    if (roles.contains(Roles.procurementOfficer) ||
        roles.contains(Roles.procurementManager)) {
      return procurement;
    }
    if (roles.contains(Roles.admin)) return administration;
    return unknown;
  }
}
