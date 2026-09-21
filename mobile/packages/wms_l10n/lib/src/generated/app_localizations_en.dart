// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitleMobile => 'WMS Warehouse';

  @override
  String get appTitleWeb => 'WMS Procurement & Warehouse';

  @override
  String get navWarehouse => 'Warehouse';

  @override
  String get navDocuments => 'Documents';

  @override
  String get navProcurement => 'Procurement';

  @override
  String get navMasterData => 'Master Data';

  @override
  String get navReports => 'Reports';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAdmin => 'Admin';

  @override
  String get docReceipt => 'Goods receipt';

  @override
  String get docIssue => 'Issue';

  @override
  String get docTransfer => 'Transfer';

  @override
  String get docCount => 'Inventory count';

  @override
  String get docWaste => 'Waste';

  @override
  String get docSample => 'Sample';

  @override
  String get docStockRequest => 'Stock request';

  @override
  String get docRequisition => 'PR';

  @override
  String get docRequisitionLong => 'Purchase requisition (PR)';

  @override
  String get docPurchaseOrder => 'PO';

  @override
  String get docPurchaseOrderLong => 'Purchase order (PO)';

  @override
  String get docRfq => 'RFQ';

  @override
  String get docQuotation => 'Quotation';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionPost => 'Post';

  @override
  String get actionApprove => 'Approve';

  @override
  String get actionReject => 'Reject';

  @override
  String get actionConfirmReceipt => 'Confirm receipt';

  @override
  String get actionDispatch => 'Dispatch';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionLogin => 'Sign in';

  @override
  String get actionLogout => 'Sign out';

  @override
  String get actionScan => 'Scan barcode';

  @override
  String get actionExport => 'Export to Excel';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionAddLine => 'Add line';

  @override
  String get actionSelect => 'Select';

  @override
  String get labelBalances => 'Balances';

  @override
  String get labelProducts => 'Products';

  @override
  String get labelSuppliers => 'Suppliers';

  @override
  String get labelLocations => 'Locations';

  @override
  String get labelUoms => 'Units of measure';

  @override
  String get labelPriceHistory => 'Price history';

  @override
  String get labelComparison => 'Quotation comparison';

  @override
  String get labelUsers => 'Users';

  @override
  String get labelRoles => 'Roles';

  @override
  String get labelSettings => 'Settings';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelDate => 'Date';

  @override
  String get labelQuantity => 'Quantity';

  @override
  String get labelProduct => 'Product';

  @override
  String get labelLocation => 'Location';

  @override
  String get labelSupplier => 'Supplier';

  @override
  String get labelReasonCode => 'Reason code';

  @override
  String get labelNote => 'Note';

  @override
  String get labelVarianceNote => 'Variance note';

  @override
  String get labelSelectionNote => 'Selection justification';

  @override
  String get labelBatchNo => 'Batch number';

  @override
  String get labelExpiryDate => 'Expiry date';

  @override
  String get labelOrdered => 'Ordered';

  @override
  String get labelReceived => 'Received';

  @override
  String get labelBook => 'Book quantity';

  @override
  String get labelCounted => 'Counted';

  @override
  String get labelVariance => 'Variance';

  @override
  String get labelPhoto => 'Photo';

  @override
  String get labelUnread => 'Unread';

  @override
  String get labelAll => 'All';

  @override
  String get labelLoading => 'Loading…';

  @override
  String get labelNoPermission => 'You do not have permission for this action';

  @override
  String labelSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String labelUnreadCount(int count) {
    return '$count unread notifications';
  }

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationVarianceNoteRequired =>
      'Quantity differs from the order — a variance note is required';

  @override
  String get validationReasonCodeRequired =>
      'Variance is not zero — a reason code is required';

  @override
  String get validationSelectionNoteRequired =>
      'The cheapest quotation was not selected — a justification is required';

  @override
  String get validationNegativeQty => 'Quantity cannot be negative';

  @override
  String get emptyBalances =>
      'No stock at this location. Create a goods receipt.';

  @override
  String get emptyDocuments => 'No documents yet. Create a new document.';

  @override
  String get emptyNotifications => 'No unread notifications.';

  @override
  String get loginSubtitle => 'Sign in with your corporate account to continue';

  @override
  String get loginFailed => 'Sign-in failed';

  @override
  String get navConsumption => 'Consumption';

  @override
  String get navBranch => 'Branch';

  @override
  String get consDailySales => 'Daily sales';

  @override
  String get consResult => 'Consumption result';

  @override
  String get consRecipeCatalog => 'Recipe catalogue';

  @override
  String get consRecipeEditor => 'Recipe editor';

  @override
  String get consSalesImport => 'Sales import';

  @override
  String get consJournal => 'Consumption journal';

  @override
  String get consVarianceReport => 'Variance report';

  @override
  String get consLabelMenuItem => 'Menu item';

  @override
  String get consLabelSold => 'Sold';

  @override
  String get consLabelBusinessDate => 'Business date';

  @override
  String get consLabelTheoretical => 'Theoretical';

  @override
  String get consLabelPosted => 'Posted';

  @override
  String get consLabelShortfall => 'Shortfall';

  @override
  String get consLabelYieldPct => 'Yield, %';

  @override
  String get consLabelAttachRatePct => 'Attach rate, %';

  @override
  String get consLabelQtyPerPortion => 'Per portion';

  @override
  String get consLabelComponent => 'Component';

  @override
  String get consLabelComponentType => 'Component type';

  @override
  String get consLabelOptional => 'Optional';

  @override
  String get consLabelValidFrom => 'Valid from';

  @override
  String get consLabelValidTo => 'Valid to';

  @override
  String get consLabelVersion => 'Version';

  @override
  String get consLabelPortions => 'Portions';

  @override
  String get consLabelExplosion => 'BOM explosion';

  @override
  String get consLabelUnmapped => 'Unmapped';

  @override
  String get consLabelTotalSold => 'Total sold';

  @override
  String get consLabelSource => 'Source';

  @override
  String get consLabelPosCode => 'POS code';

  @override
  String get consLabelColumnMapping => 'Column mapping';

  @override
  String get consLabelParseErrors => 'Rows that could not be read';

  @override
  String get consLabelRow => 'Row';

  @override
  String get consLabelExpected => 'Expected';

  @override
  String get consLabelOpening => 'Opening';

  @override
  String get consLabelPeriodFrom => 'Period from';

  @override
  String get consLabelPeriodTo => 'Period to';

  @override
  String get consLabelCompliancePct => 'Compliance, %';

  @override
  String get consLabelRecipeMissing => 'No recipe';

  @override
  String get consLabelSubRecipe => 'Sub-recipe';

  @override
  String get consLabelFoodProduct => 'Warehouse product';

  @override
  String get consLabelLineCount => 'Lines';

  @override
  String get consLabelDocNo => 'Document';

  @override
  String get consLabelFile => 'File';

  @override
  String get consActionSubmitSales => 'Submit sales';

  @override
  String get consActionCalculate => 'Calculate';

  @override
  String get consActionReverse => 'Reverse';

  @override
  String get consActionActivate => 'Activate';

  @override
  String get consActionNewVersion => 'New version';

  @override
  String get consActionUploadCsv => 'Upload CSV';

  @override
  String get consActionChooseFile => 'Choose file';

  @override
  String get consActionAddComponent => 'Add component';

  @override
  String get consActionMapPosCode => 'Map to a menu item';

  @override
  String get consEmptySalesReason => 'No sales have been entered for this day.';

  @override
  String get consEmptySalesNext =>
      'Find the menu item and type how many were sold.';

  @override
  String get consEmptyMenuItemsReason => 'No menu item found.';

  @override
  String get consEmptyMenuItemsNext =>
      'Change the search or ask the manager to create the menu item.';

  @override
  String get consEmptyResultReason =>
      'There is no consumption document for this date.';

  @override
  String get consEmptyResultNext =>
      'Submit the sales; the calculation runs overnight and the result appears here.';

  @override
  String get consEmptyRunsReason =>
      'No consumption document matches the filter.';

  @override
  String get consEmptyRunsNext =>
      'Widen the date range or create a document from a sales import.';

  @override
  String get consEmptyImportsReason => 'No sales import matches the filter.';

  @override
  String get consEmptyImportsNext =>
      'Upload a CSV or let the branch enter the day\'s sales on mobile.';

  @override
  String get consEmptyRecipeLinesReason => 'This version has no components.';

  @override
  String get consEmptyRecipeLinesNext =>
      'Add a component — an empty recipe cannot be activated.';

  @override
  String get consEmptyVersionsReason => 'This menu item has no recipe.';

  @override
  String get consEmptyVersionsNext =>
      'Create a version, fill in the components and activate it.';

  @override
  String get consEmptyVarianceReason =>
      'No variance rows in the selected period.';

  @override
  String get consEmptyVarianceNext =>
      'Pick the period between two counts — the report runs from count to count.';

  @override
  String get consEmptyExplosionReason => 'The explosion result is empty.';

  @override
  String get consEmptyExplosionNext =>
      'Add components and save; the preview refreshes afterwards.';

  @override
  String get consShortfallTitle => 'Stock ran out';

  @override
  String get consShortfallExplained =>
      'Part of the theoretical consumption could not be taken off stock because the balance was exhausted. A goods receipt was most likely not recorded — check the incoming deliveries.';

  @override
  String get consUnmappedTitle => 'Sales without a recipe';

  @override
  String get consUnmappedExplained =>
      'These lines produced no depletion: the menu item was not recognised or it has no recipe.';

  @override
  String get consNoRecipeWarning =>
      'Some menu items have no recipe — their sales take nothing off stock.';

  @override
  String get consAlreadySubmitted =>
      'Today\'s sales have already been submitted';

  @override
  String get consAlreadySubmittedHint =>
      'One document per day. Ask the manager if a correction is needed.';

  @override
  String get consReverseReasonRequired =>
      'A reason code is mandatory for a reversal';

  @override
  String get consReverseTitle => 'Reverse the consumption';

  @override
  String get consReverseMessage =>
      'A posted document is never edited. The reversal creates a new movement group and frees the day for a new calculation.';

  @override
  String get consYieldHint =>
      'Processing loss: entering 92 takes more off stock than the recipe states.';

  @override
  String get consPreviewPending =>
      'There are unsaved changes — the figures below are calculated locally.';

  @override
  String get consPreviewServer => 'Server explosion';

  @override
  String get consSubRecipeNeedsSave =>
      'A sub-recipe is only exploded after the draft is saved.';

  @override
  String get consErrRecipeCycle =>
      'The sub-recipes form a cycle (A → B → A). Change the sub-recipe component.';

  @override
  String get consErrRecipeDepth =>
      'Sub-recipe nesting is deeper than 5. Shorten the chain.';

  @override
  String get consErrRecipeEmpty =>
      'A recipe without components cannot be activated. Add at least one line.';

  @override
  String get consErrPeriodClosed =>
      'A consumption document is already posted before this date. Pick a later date.';

  @override
  String get consErrDuplicateBusinessDate =>
      'A document already exists for this branch and day. Open the existing one.';

  @override
  String get consErrUomFactorMissing =>
      'There is no unit conversion factor for this date. Check the unit in Master Data.';

  @override
  String get consErrFileTooLarge =>
      'The file is larger than 5 MB. Split the report and upload it again.';
}
