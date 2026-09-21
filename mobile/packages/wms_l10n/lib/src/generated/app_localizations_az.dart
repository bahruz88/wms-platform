// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get appTitleMobile => 'WMS Anbar';

  @override
  String get appTitleWeb => 'WMS Satınalma və Anbar';

  @override
  String get navWarehouse => 'Anbar';

  @override
  String get navDocuments => 'Sənədlər';

  @override
  String get navProcurement => 'Satınalma';

  @override
  String get navMasterData => 'Master Data';

  @override
  String get navReports => 'Hesabatlar';

  @override
  String get navNotifications => 'Bildirişlər';

  @override
  String get navProfile => 'Profil';

  @override
  String get navDashboard => 'İdarə paneli';

  @override
  String get navAdmin => 'Admin';

  @override
  String get docReceipt => 'Qəbul';

  @override
  String get docIssue => 'Məxaric';

  @override
  String get docTransfer => 'Transfer';

  @override
  String get docCount => 'Sayım';

  @override
  String get docWaste => 'Tullantı';

  @override
  String get docSample => 'Nümunə';

  @override
  String get docStockRequest => 'Anbar tələbi';

  @override
  String get docRequisition => 'PR';

  @override
  String get docRequisitionLong => 'Satınalma tələbi (PR)';

  @override
  String get docPurchaseOrder => 'PO';

  @override
  String get docPurchaseOrderLong => 'Satınalma sifarişi (PO)';

  @override
  String get docRfq => 'RFQ';

  @override
  String get docQuotation => 'Təklif';

  @override
  String get actionSave => 'Yadda saxla';

  @override
  String get actionCreate => 'Yarat';

  @override
  String get actionPost => 'Post et';

  @override
  String get actionApprove => 'Təsdiqlə';

  @override
  String get actionReject => 'Rədd et';

  @override
  String get actionConfirmReceipt => 'Qəbulu təsdiq et';

  @override
  String get actionDispatch => 'Yola sal';

  @override
  String get actionCancel => 'İmtina';

  @override
  String get actionRetry => 'Yenidən cəhd et';

  @override
  String get actionLogin => 'Daxil ol';

  @override
  String get actionLogout => 'Çıxış';

  @override
  String get actionScan => 'Barkod skan et';

  @override
  String get actionExport => 'Excel-ə çıxar';

  @override
  String get actionSearch => 'Axtar';

  @override
  String get actionAddLine => 'Sətir əlavə et';

  @override
  String get actionSelect => 'Seç';

  @override
  String get labelBalances => 'Qalıqlar';

  @override
  String get labelProducts => 'Məhsullar';

  @override
  String get labelSuppliers => 'Təchizatçılar';

  @override
  String get labelLocations => 'Lokasiyalar';

  @override
  String get labelUoms => 'Ölçü vahidləri';

  @override
  String get labelPriceHistory => 'Qiymət tarixçəsi';

  @override
  String get labelComparison => 'Təkliflərin müqayisəsi';

  @override
  String get labelUsers => 'İstifadəçilər';

  @override
  String get labelRoles => 'Rollar';

  @override
  String get labelSettings => 'Parametrlər';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelDate => 'Tarix';

  @override
  String get labelQuantity => 'Miqdar';

  @override
  String get labelProduct => 'Məhsul';

  @override
  String get labelLocation => 'Lokasiya';

  @override
  String get labelSupplier => 'Təchizatçı';

  @override
  String get labelReasonCode => 'Səbəb kodu';

  @override
  String get labelNote => 'Qeyd';

  @override
  String get labelVarianceNote => 'Fərq qeydi';

  @override
  String get labelSelectionNote => 'Seçim əsaslandırması';

  @override
  String get labelBatchNo => 'Partiya nömrəsi';

  @override
  String get labelExpiryDate => 'Son istifadə tarixi';

  @override
  String get labelOrdered => 'Sifariş';

  @override
  String get labelReceived => 'Qəbul edilən';

  @override
  String get labelBook => 'Sistem qalığı';

  @override
  String get labelCounted => 'Sayılan';

  @override
  String get labelVariance => 'Fərq';

  @override
  String get labelPhoto => 'Foto';

  @override
  String get labelUnread => 'Oxunmamış';

  @override
  String get labelAll => 'Hamısı';

  @override
  String get labelLoading => 'Yüklənir…';

  @override
  String get labelNoPermission => 'Bu əməliyyat üçün icazəniz yoxdur';

  @override
  String labelSignedInAs(String name) {
    return '$name kimi daxil olmusunuz';
  }

  @override
  String labelUnreadCount(int count) {
    return '$count oxunmamış bildiriş';
  }

  @override
  String get errorGeneric => 'Xəta baş verdi';

  @override
  String get errorNetwork => 'Şəbəkə xətası. Bağlantını yoxlayın.';

  @override
  String get validationRequired => 'Bu sahə məcburidir';

  @override
  String get validationVarianceNoteRequired =>
      'Miqdar sifarişdən fərqlənir — fərq qeydi məcburidir';

  @override
  String get validationReasonCodeRequired =>
      'Fərq sıfır deyil — səbəb kodu məcburidir';

  @override
  String get validationSelectionNoteRequired =>
      'Ən ucuz təklif seçilmədi — əsaslandırma məcburidir';

  @override
  String get validationNegativeQty => 'Miqdar mənfi ola bilməz';

  @override
  String get emptyBalances =>
      'Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın.';

  @override
  String get emptyDocuments => 'Hələ sənəd yoxdur. Yeni sənəd yaradın.';

  @override
  String get emptyNotifications => 'Oxunmamış bildiriş yoxdur.';

  @override
  String get loginSubtitle =>
      'Davam etmək üçün korporativ hesabınızla daxil olun';

  @override
  String get loginFailed => 'Daxil olmaq mümkün olmadı';

  @override
  String get navConsumption => 'İstehlak';

  @override
  String get navBranch => 'Filial';

  @override
  String get consDailySales => 'Günün satışı';

  @override
  String get consResult => 'İstehlak nəticəsi';

  @override
  String get consRecipeCatalog => 'Resept kataloqu';

  @override
  String get consRecipeEditor => 'Resept redaktoru';

  @override
  String get consSalesImport => 'Satış importu';

  @override
  String get consJournal => 'İstehlak jurnalı';

  @override
  String get consVarianceReport => 'Fərq hesabatı';

  @override
  String get consLabelMenuItem => 'Menyu maddəsi';

  @override
  String get consLabelSold => 'Satılan';

  @override
  String get consLabelBusinessDate => 'İş günü';

  @override
  String get consLabelTheoretical => 'Nəzəri';

  @override
  String get consLabelPosted => 'Post edilən';

  @override
  String get consLabelShortfall => 'Çatışmazlıq';

  @override
  String get consLabelYieldPct => 'Emal çıxımı, %';

  @override
  String get consLabelAttachRatePct => 'Götürülmə faizi, %';

  @override
  String get consLabelQtyPerPortion => 'Porsiyaya düşən';

  @override
  String get consLabelComponent => 'Tərkib';

  @override
  String get consLabelComponentType => 'Tərkib növü';

  @override
  String get consLabelOptional => 'Opsional';

  @override
  String get consLabelValidFrom => 'Etibarlıdır';

  @override
  String get consLabelValidTo => 'Bitir';

  @override
  String get consLabelVersion => 'Versiya';

  @override
  String get consLabelPortions => 'Porsiya';

  @override
  String get consLabelExplosion => 'BOM partlaması';

  @override
  String get consLabelUnmapped => 'Tanınmayan';

  @override
  String get consLabelTotalSold => 'Cəmi satılan';

  @override
  String get consLabelSource => 'Mənbə';

  @override
  String get consLabelPosCode => 'POS kodu';

  @override
  String get consLabelColumnMapping => 'Sütun xəritəsi';

  @override
  String get consLabelParseErrors => 'Oxuna bilməyən sətirlər';

  @override
  String get consLabelRow => 'Sətir';

  @override
  String get consLabelExpected => 'Gözlənilən';

  @override
  String get consLabelOpening => 'Dövrün əvvəli';

  @override
  String get consLabelPeriodFrom => 'Dövrün başlanğıcı';

  @override
  String get consLabelPeriodTo => 'Dövrün sonu';

  @override
  String get consLabelCompliancePct => 'Uyğunluq, %';

  @override
  String get consLabelRecipeMissing => 'Resept yoxdur';

  @override
  String get consLabelSubRecipe => 'Alt-resept';

  @override
  String get consLabelFoodProduct => 'Anbar məhsulu';

  @override
  String get consLabelLineCount => 'Sətir sayı';

  @override
  String get consLabelDocNo => 'Sənəd';

  @override
  String get consLabelFile => 'Fayl';

  @override
  String get consActionSubmitSales => 'Satışı təsdiqlə';

  @override
  String get consActionCalculate => 'Hesabla';

  @override
  String get consActionReverse => 'Storno et';

  @override
  String get consActionActivate => 'Aktivləşdir';

  @override
  String get consActionNewVersion => 'Yeni versiya';

  @override
  String get consActionUploadCsv => 'CSV yüklə';

  @override
  String get consActionChooseFile => 'Fayl seç';

  @override
  String get consActionAddComponent => 'Tərkib əlavə et';

  @override
  String get consActionMapPosCode => 'Menyu maddəsinə bağla';

  @override
  String get consEmptySalesReason => 'Bu gün üçün satış daxil edilməyib.';

  @override
  String get consEmptySalesNext =>
      'Menyu maddəsini tapın və satılan sayı yazın.';

  @override
  String get consEmptyMenuItemsReason => 'Menyu maddəsi tapılmadı.';

  @override
  String get consEmptyMenuItemsNext =>
      'Axtarışı dəyişin və ya menecerdən menyu maddəsi yaratmasını istəyin.';

  @override
  String get consEmptyResultReason => 'Bu tarix üçün istehlak sənədi yoxdur.';

  @override
  String get consEmptyResultNext =>
      'Satışı təsdiqləyin — hesablama gecə işləyir, sonra nəticə burada görünür.';

  @override
  String get consEmptyRunsReason =>
      'Seçilmiş filtrə uyğun istehlak sənədi yoxdur.';

  @override
  String get consEmptyRunsNext =>
      'Tarix aralığını genişləndirin və ya satış importundan yeni sənəd yaradın.';

  @override
  String get consEmptyImportsReason =>
      'Seçilmiş filtrə uyğun satış importu yoxdur.';

  @override
  String get consEmptyImportsNext =>
      'CSV yükləyin və ya filial mobil tətbiqdən günün satışını daxil etsin.';

  @override
  String get consEmptyRecipeLinesReason => 'Bu versiyanın tərkibi boşdur.';

  @override
  String get consEmptyRecipeLinesNext =>
      'Tərkib əlavə edin — boş resept aktivləşdirilə bilməz.';

  @override
  String get consEmptyVersionsReason => 'Bu menyu maddəsinin resepti yoxdur.';

  @override
  String get consEmptyVersionsNext =>
      'Yeni versiya yaradın, tərkibi doldurun və aktivləşdirin.';

  @override
  String get consEmptyVarianceReason => 'Seçilmiş dövrdə fərq sətri yoxdur.';

  @override
  String get consEmptyVarianceNext =>
      'İki sayım arasındakı dövrü seçin — hesabat sayımdan sayıma işləyir.';

  @override
  String get consEmptyExplosionReason => 'Partlama nəticəsi boşdur.';

  @override
  String get consEmptyExplosionNext =>
      'Tərkib əlavə edib yadda saxlayın, sonra önizləmə yenilənir.';

  @override
  String get consShortfallTitle => 'Qalıq çatmadı';

  @override
  String get consShortfallExplained =>
      'Nəzəri məxaricin bir hissəsi stokdan çıxarıla bilmədi, çünki qalıq tükənmişdi. Çox güman ki, qəbul qeyd olunmayıb — gələn malı yoxlayın.';

  @override
  String get consUnmappedTitle => 'Resepti olmayan satış';

  @override
  String get consUnmappedExplained =>
      'Bu sətirlər məxaric yaratmadı: menyu maddəsi tanınmadı və ya onun resepti yoxdur.';

  @override
  String get consNoRecipeWarning =>
      'Resepti olmayan menyu maddələri var — onların satışı stokdan heç nə çıxarmır.';

  @override
  String get consAlreadySubmitted => 'Bu günün satışı artıq təsdiqlənib';

  @override
  String get consAlreadySubmittedHint =>
      'Bir gün üçün bir sənəd olur. Düzəliş lazımdırsa menecerə müraciət edin.';

  @override
  String get consReverseReasonRequired => 'Storno üçün səbəb kodu məcburidir';

  @override
  String get consReverseTitle => 'İstehlakı storno et';

  @override
  String get consReverseMessage =>
      'Post edilmiş sənəd redaktə olunmur. Storno yeni hərəkət qrupu yaradır və həmin gün üçün yenidən hesablamağa imkan verir.';

  @override
  String get consYieldHint =>
      'Emal itkisi: 92 yazsanız stokdan qeyd olunandan çox çıxır.';

  @override
  String get consPreviewPending =>
      'Yadda saxlanmamış dəyişikliklər var — aşağıdakı rəqəmlər yerli hesablamadır.';

  @override
  String get consPreviewServer => 'Server partlaması';

  @override
  String get consSubRecipeNeedsSave =>
      'Alt-resept yalnız yadda saxlandıqdan sonra açılır.';

  @override
  String get consErrRecipeCycle =>
      'Alt-reseptlər dövrə yaradır (A → B → A). Tərkibdəki alt-resepti dəyişin.';

  @override
  String get consErrRecipeDepth =>
      'Alt-resept dərinliyi 5-dən çoxdur. Zənciri qısaldın.';

  @override
  String get consErrRecipeEmpty =>
      'Tərkibi boş resept aktivləşdirilə bilməz. Ən azı bir sətir əlavə edin.';

  @override
  String get consErrPeriodClosed =>
      'Bu tarixdən əvvəl post edilmiş istehlak sənədi var. Daha sonrakı tarix seçin.';

  @override
  String get consErrDuplicateBusinessDate =>
      'Bu filial və gün üçün sənəd artıq mövcuddur. Mövcud sənədi açın.';

  @override
  String get consErrUomFactorMissing =>
      'Bu tarix üçün vahid çevirmə əmsalı yoxdur. Master Data-da vahidi yoxlayın.';

  @override
  String get consErrFileTooLarge =>
      'Fayl 5 MB-dan böyükdür. Hesabatı bölüb yükləyin.';
}
