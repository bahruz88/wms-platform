import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('az'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitleMobile.
  ///
  /// In az, this message translates to:
  /// **'WMS Anbar'**
  String get appTitleMobile;

  /// No description provided for @appTitleWeb.
  ///
  /// In az, this message translates to:
  /// **'WMS Satınalma və Anbar'**
  String get appTitleWeb;

  /// No description provided for @navWarehouse.
  ///
  /// In az, this message translates to:
  /// **'Anbar'**
  String get navWarehouse;

  /// No description provided for @navDocuments.
  ///
  /// In az, this message translates to:
  /// **'Sənədlər'**
  String get navDocuments;

  /// No description provided for @navProcurement.
  ///
  /// In az, this message translates to:
  /// **'Satınalma'**
  String get navProcurement;

  /// No description provided for @navMasterData.
  ///
  /// In az, this message translates to:
  /// **'Master Data'**
  String get navMasterData;

  /// No description provided for @navReports.
  ///
  /// In az, this message translates to:
  /// **'Hesabatlar'**
  String get navReports;

  /// No description provided for @navNotifications.
  ///
  /// In az, this message translates to:
  /// **'Bildirişlər'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In az, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navDashboard.
  ///
  /// In az, this message translates to:
  /// **'İdarə paneli'**
  String get navDashboard;

  /// No description provided for @navAdmin.
  ///
  /// In az, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @docReceipt.
  ///
  /// In az, this message translates to:
  /// **'Qəbul'**
  String get docReceipt;

  /// No description provided for @docIssue.
  ///
  /// In az, this message translates to:
  /// **'Məxaric'**
  String get docIssue;

  /// No description provided for @docTransfer.
  ///
  /// In az, this message translates to:
  /// **'Transfer'**
  String get docTransfer;

  /// No description provided for @docCount.
  ///
  /// In az, this message translates to:
  /// **'Sayım'**
  String get docCount;

  /// No description provided for @docWaste.
  ///
  /// In az, this message translates to:
  /// **'Tullantı'**
  String get docWaste;

  /// No description provided for @docSample.
  ///
  /// In az, this message translates to:
  /// **'Nümunə'**
  String get docSample;

  /// No description provided for @docStockRequest.
  ///
  /// In az, this message translates to:
  /// **'Anbar tələbi'**
  String get docStockRequest;

  /// No description provided for @docRequisition.
  ///
  /// In az, this message translates to:
  /// **'PR'**
  String get docRequisition;

  /// No description provided for @docRequisitionLong.
  ///
  /// In az, this message translates to:
  /// **'Satınalma tələbi (PR)'**
  String get docRequisitionLong;

  /// No description provided for @docPurchaseOrder.
  ///
  /// In az, this message translates to:
  /// **'PO'**
  String get docPurchaseOrder;

  /// No description provided for @docPurchaseOrderLong.
  ///
  /// In az, this message translates to:
  /// **'Satınalma sifarişi (PO)'**
  String get docPurchaseOrderLong;

  /// No description provided for @docRfq.
  ///
  /// In az, this message translates to:
  /// **'RFQ'**
  String get docRfq;

  /// No description provided for @docQuotation.
  ///
  /// In az, this message translates to:
  /// **'Təklif'**
  String get docQuotation;

  /// No description provided for @actionSave.
  ///
  /// In az, this message translates to:
  /// **'Yadda saxla'**
  String get actionSave;

  /// No description provided for @actionCreate.
  ///
  /// In az, this message translates to:
  /// **'Yarat'**
  String get actionCreate;

  /// No description provided for @actionPost.
  ///
  /// In az, this message translates to:
  /// **'Post et'**
  String get actionPost;

  /// No description provided for @actionApprove.
  ///
  /// In az, this message translates to:
  /// **'Təsdiqlə'**
  String get actionApprove;

  /// No description provided for @actionReject.
  ///
  /// In az, this message translates to:
  /// **'Rədd et'**
  String get actionReject;

  /// No description provided for @actionConfirmReceipt.
  ///
  /// In az, this message translates to:
  /// **'Qəbulu təsdiq et'**
  String get actionConfirmReceipt;

  /// No description provided for @actionDispatch.
  ///
  /// In az, this message translates to:
  /// **'Yola sal'**
  String get actionDispatch;

  /// No description provided for @actionCancel.
  ///
  /// In az, this message translates to:
  /// **'İmtina'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In az, this message translates to:
  /// **'Yenidən cəhd et'**
  String get actionRetry;

  /// No description provided for @actionLogin.
  ///
  /// In az, this message translates to:
  /// **'Daxil ol'**
  String get actionLogin;

  /// No description provided for @actionLogout.
  ///
  /// In az, this message translates to:
  /// **'Çıxış'**
  String get actionLogout;

  /// No description provided for @actionScan.
  ///
  /// In az, this message translates to:
  /// **'Barkod skan et'**
  String get actionScan;

  /// No description provided for @actionExport.
  ///
  /// In az, this message translates to:
  /// **'Excel-ə çıxar'**
  String get actionExport;

  /// No description provided for @actionSearch.
  ///
  /// In az, this message translates to:
  /// **'Axtar'**
  String get actionSearch;

  /// No description provided for @actionAddLine.
  ///
  /// In az, this message translates to:
  /// **'Sətir əlavə et'**
  String get actionAddLine;

  /// No description provided for @actionSelect.
  ///
  /// In az, this message translates to:
  /// **'Seç'**
  String get actionSelect;

  /// No description provided for @labelBalances.
  ///
  /// In az, this message translates to:
  /// **'Qalıqlar'**
  String get labelBalances;

  /// No description provided for @labelProducts.
  ///
  /// In az, this message translates to:
  /// **'Məhsullar'**
  String get labelProducts;

  /// No description provided for @labelSuppliers.
  ///
  /// In az, this message translates to:
  /// **'Təchizatçılar'**
  String get labelSuppliers;

  /// No description provided for @labelLocations.
  ///
  /// In az, this message translates to:
  /// **'Lokasiyalar'**
  String get labelLocations;

  /// No description provided for @labelUoms.
  ///
  /// In az, this message translates to:
  /// **'Ölçü vahidləri'**
  String get labelUoms;

  /// No description provided for @labelPriceHistory.
  ///
  /// In az, this message translates to:
  /// **'Qiymət tarixçəsi'**
  String get labelPriceHistory;

  /// No description provided for @labelComparison.
  ///
  /// In az, this message translates to:
  /// **'Təkliflərin müqayisəsi'**
  String get labelComparison;

  /// No description provided for @labelUsers.
  ///
  /// In az, this message translates to:
  /// **'İstifadəçilər'**
  String get labelUsers;

  /// No description provided for @labelRoles.
  ///
  /// In az, this message translates to:
  /// **'Rollar'**
  String get labelRoles;

  /// No description provided for @labelSettings.
  ///
  /// In az, this message translates to:
  /// **'Parametrlər'**
  String get labelSettings;

  /// No description provided for @labelStatus.
  ///
  /// In az, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @labelDate.
  ///
  /// In az, this message translates to:
  /// **'Tarix'**
  String get labelDate;

  /// No description provided for @labelQuantity.
  ///
  /// In az, this message translates to:
  /// **'Miqdar'**
  String get labelQuantity;

  /// No description provided for @labelProduct.
  ///
  /// In az, this message translates to:
  /// **'Məhsul'**
  String get labelProduct;

  /// No description provided for @labelLocation.
  ///
  /// In az, this message translates to:
  /// **'Lokasiya'**
  String get labelLocation;

  /// No description provided for @labelSupplier.
  ///
  /// In az, this message translates to:
  /// **'Təchizatçı'**
  String get labelSupplier;

  /// No description provided for @labelReasonCode.
  ///
  /// In az, this message translates to:
  /// **'Səbəb kodu'**
  String get labelReasonCode;

  /// No description provided for @labelNote.
  ///
  /// In az, this message translates to:
  /// **'Qeyd'**
  String get labelNote;

  /// No description provided for @labelVarianceNote.
  ///
  /// In az, this message translates to:
  /// **'Fərq qeydi'**
  String get labelVarianceNote;

  /// No description provided for @labelSelectionNote.
  ///
  /// In az, this message translates to:
  /// **'Seçim əsaslandırması'**
  String get labelSelectionNote;

  /// No description provided for @labelBatchNo.
  ///
  /// In az, this message translates to:
  /// **'Partiya nömrəsi'**
  String get labelBatchNo;

  /// No description provided for @labelExpiryDate.
  ///
  /// In az, this message translates to:
  /// **'Son istifadə tarixi'**
  String get labelExpiryDate;

  /// No description provided for @labelOrdered.
  ///
  /// In az, this message translates to:
  /// **'Sifariş'**
  String get labelOrdered;

  /// No description provided for @labelReceived.
  ///
  /// In az, this message translates to:
  /// **'Qəbul edilən'**
  String get labelReceived;

  /// No description provided for @labelBook.
  ///
  /// In az, this message translates to:
  /// **'Sistem qalığı'**
  String get labelBook;

  /// No description provided for @labelCounted.
  ///
  /// In az, this message translates to:
  /// **'Sayılan'**
  String get labelCounted;

  /// No description provided for @labelVariance.
  ///
  /// In az, this message translates to:
  /// **'Fərq'**
  String get labelVariance;

  /// No description provided for @labelPhoto.
  ///
  /// In az, this message translates to:
  /// **'Foto'**
  String get labelPhoto;

  /// No description provided for @labelUnread.
  ///
  /// In az, this message translates to:
  /// **'Oxunmamış'**
  String get labelUnread;

  /// No description provided for @labelAll.
  ///
  /// In az, this message translates to:
  /// **'Hamısı'**
  String get labelAll;

  /// No description provided for @labelLoading.
  ///
  /// In az, this message translates to:
  /// **'Yüklənir…'**
  String get labelLoading;

  /// No description provided for @labelNoPermission.
  ///
  /// In az, this message translates to:
  /// **'Bu əməliyyat üçün icazəniz yoxdur'**
  String get labelNoPermission;

  /// No description provided for @labelSignedInAs.
  ///
  /// In az, this message translates to:
  /// **'{name} kimi daxil olmusunuz'**
  String labelSignedInAs(String name);

  /// No description provided for @labelUnreadCount.
  ///
  /// In az, this message translates to:
  /// **'{count} oxunmamış bildiriş'**
  String labelUnreadCount(int count);

  /// No description provided for @errorGeneric.
  ///
  /// In az, this message translates to:
  /// **'Xəta baş verdi'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In az, this message translates to:
  /// **'Şəbəkə xətası. Bağlantını yoxlayın.'**
  String get errorNetwork;

  /// No description provided for @validationRequired.
  ///
  /// In az, this message translates to:
  /// **'Bu sahə məcburidir'**
  String get validationRequired;

  /// No description provided for @validationVarianceNoteRequired.
  ///
  /// In az, this message translates to:
  /// **'Miqdar sifarişdən fərqlənir — fərq qeydi məcburidir'**
  String get validationVarianceNoteRequired;

  /// No description provided for @validationReasonCodeRequired.
  ///
  /// In az, this message translates to:
  /// **'Fərq sıfır deyil — səbəb kodu məcburidir'**
  String get validationReasonCodeRequired;

  /// No description provided for @validationSelectionNoteRequired.
  ///
  /// In az, this message translates to:
  /// **'Ən ucuz təklif seçilmədi — əsaslandırma məcburidir'**
  String get validationSelectionNoteRequired;

  /// No description provided for @validationNegativeQty.
  ///
  /// In az, this message translates to:
  /// **'Miqdar mənfi ola bilməz'**
  String get validationNegativeQty;

  /// No description provided for @emptyBalances.
  ///
  /// In az, this message translates to:
  /// **'Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın.'**
  String get emptyBalances;

  /// No description provided for @emptyDocuments.
  ///
  /// In az, this message translates to:
  /// **'Hələ sənəd yoxdur. Yeni sənəd yaradın.'**
  String get emptyDocuments;

  /// No description provided for @emptyNotifications.
  ///
  /// In az, this message translates to:
  /// **'Oxunmamış bildiriş yoxdur.'**
  String get emptyNotifications;

  /// No description provided for @loginSubtitle.
  ///
  /// In az, this message translates to:
  /// **'Davam etmək üçün korporativ hesabınızla daxil olun'**
  String get loginSubtitle;

  /// No description provided for @loginFailed.
  ///
  /// In az, this message translates to:
  /// **'Daxil olmaq mümkün olmadı'**
  String get loginFailed;

  /// No description provided for @navConsumption.
  ///
  /// In az, this message translates to:
  /// **'İstehlak'**
  String get navConsumption;

  /// No description provided for @navBranch.
  ///
  /// In az, this message translates to:
  /// **'Filial'**
  String get navBranch;

  /// No description provided for @consDailySales.
  ///
  /// In az, this message translates to:
  /// **'Günün satışı'**
  String get consDailySales;

  /// No description provided for @consResult.
  ///
  /// In az, this message translates to:
  /// **'İstehlak nəticəsi'**
  String get consResult;

  /// No description provided for @consRecipeCatalog.
  ///
  /// In az, this message translates to:
  /// **'Resept kataloqu'**
  String get consRecipeCatalog;

  /// No description provided for @consRecipeEditor.
  ///
  /// In az, this message translates to:
  /// **'Resept redaktoru'**
  String get consRecipeEditor;

  /// No description provided for @consSalesImport.
  ///
  /// In az, this message translates to:
  /// **'Satış importu'**
  String get consSalesImport;

  /// No description provided for @consJournal.
  ///
  /// In az, this message translates to:
  /// **'İstehlak jurnalı'**
  String get consJournal;

  /// No description provided for @consVarianceReport.
  ///
  /// In az, this message translates to:
  /// **'Fərq hesabatı'**
  String get consVarianceReport;

  /// No description provided for @consLabelMenuItem.
  ///
  /// In az, this message translates to:
  /// **'Menyu maddəsi'**
  String get consLabelMenuItem;

  /// No description provided for @consLabelSold.
  ///
  /// In az, this message translates to:
  /// **'Satılan'**
  String get consLabelSold;

  /// No description provided for @consLabelBusinessDate.
  ///
  /// In az, this message translates to:
  /// **'İş günü'**
  String get consLabelBusinessDate;

  /// No description provided for @consLabelTheoretical.
  ///
  /// In az, this message translates to:
  /// **'Nəzəri'**
  String get consLabelTheoretical;

  /// No description provided for @consLabelPosted.
  ///
  /// In az, this message translates to:
  /// **'Post edilən'**
  String get consLabelPosted;

  /// No description provided for @consLabelShortfall.
  ///
  /// In az, this message translates to:
  /// **'Çatışmazlıq'**
  String get consLabelShortfall;

  /// No description provided for @consLabelYieldPct.
  ///
  /// In az, this message translates to:
  /// **'Emal çıxımı, %'**
  String get consLabelYieldPct;

  /// No description provided for @consLabelAttachRatePct.
  ///
  /// In az, this message translates to:
  /// **'Götürülmə faizi, %'**
  String get consLabelAttachRatePct;

  /// No description provided for @consLabelQtyPerPortion.
  ///
  /// In az, this message translates to:
  /// **'Porsiyaya düşən'**
  String get consLabelQtyPerPortion;

  /// No description provided for @consLabelComponent.
  ///
  /// In az, this message translates to:
  /// **'Tərkib'**
  String get consLabelComponent;

  /// No description provided for @consLabelComponentType.
  ///
  /// In az, this message translates to:
  /// **'Tərkib növü'**
  String get consLabelComponentType;

  /// No description provided for @consLabelOptional.
  ///
  /// In az, this message translates to:
  /// **'Opsional'**
  String get consLabelOptional;

  /// No description provided for @consLabelValidFrom.
  ///
  /// In az, this message translates to:
  /// **'Etibarlıdır'**
  String get consLabelValidFrom;

  /// No description provided for @consLabelValidTo.
  ///
  /// In az, this message translates to:
  /// **'Bitir'**
  String get consLabelValidTo;

  /// No description provided for @consLabelVersion.
  ///
  /// In az, this message translates to:
  /// **'Versiya'**
  String get consLabelVersion;

  /// No description provided for @consLabelPortions.
  ///
  /// In az, this message translates to:
  /// **'Porsiya'**
  String get consLabelPortions;

  /// No description provided for @consLabelExplosion.
  ///
  /// In az, this message translates to:
  /// **'BOM partlaması'**
  String get consLabelExplosion;

  /// No description provided for @consLabelUnmapped.
  ///
  /// In az, this message translates to:
  /// **'Tanınmayan'**
  String get consLabelUnmapped;

  /// No description provided for @consLabelTotalSold.
  ///
  /// In az, this message translates to:
  /// **'Cəmi satılan'**
  String get consLabelTotalSold;

  /// No description provided for @consLabelSource.
  ///
  /// In az, this message translates to:
  /// **'Mənbə'**
  String get consLabelSource;

  /// No description provided for @consLabelPosCode.
  ///
  /// In az, this message translates to:
  /// **'POS kodu'**
  String get consLabelPosCode;

  /// No description provided for @consLabelColumnMapping.
  ///
  /// In az, this message translates to:
  /// **'Sütun xəritəsi'**
  String get consLabelColumnMapping;

  /// No description provided for @consLabelParseErrors.
  ///
  /// In az, this message translates to:
  /// **'Oxuna bilməyən sətirlər'**
  String get consLabelParseErrors;

  /// No description provided for @consLabelRow.
  ///
  /// In az, this message translates to:
  /// **'Sətir'**
  String get consLabelRow;

  /// No description provided for @consLabelExpected.
  ///
  /// In az, this message translates to:
  /// **'Gözlənilən'**
  String get consLabelExpected;

  /// No description provided for @consLabelOpening.
  ///
  /// In az, this message translates to:
  /// **'Dövrün əvvəli'**
  String get consLabelOpening;

  /// No description provided for @consLabelPeriodFrom.
  ///
  /// In az, this message translates to:
  /// **'Dövrün başlanğıcı'**
  String get consLabelPeriodFrom;

  /// No description provided for @consLabelPeriodTo.
  ///
  /// In az, this message translates to:
  /// **'Dövrün sonu'**
  String get consLabelPeriodTo;

  /// No description provided for @consLabelCompliancePct.
  ///
  /// In az, this message translates to:
  /// **'Uyğunluq, %'**
  String get consLabelCompliancePct;

  /// No description provided for @consLabelRecipeMissing.
  ///
  /// In az, this message translates to:
  /// **'Resept yoxdur'**
  String get consLabelRecipeMissing;

  /// No description provided for @consLabelSubRecipe.
  ///
  /// In az, this message translates to:
  /// **'Alt-resept'**
  String get consLabelSubRecipe;

  /// No description provided for @consLabelFoodProduct.
  ///
  /// In az, this message translates to:
  /// **'Anbar məhsulu'**
  String get consLabelFoodProduct;

  /// No description provided for @consLabelLineCount.
  ///
  /// In az, this message translates to:
  /// **'Sətir sayı'**
  String get consLabelLineCount;

  /// No description provided for @consLabelDocNo.
  ///
  /// In az, this message translates to:
  /// **'Sənəd'**
  String get consLabelDocNo;

  /// No description provided for @consLabelFile.
  ///
  /// In az, this message translates to:
  /// **'Fayl'**
  String get consLabelFile;

  /// No description provided for @consActionSubmitSales.
  ///
  /// In az, this message translates to:
  /// **'Satışı təsdiqlə'**
  String get consActionSubmitSales;

  /// No description provided for @consActionCalculate.
  ///
  /// In az, this message translates to:
  /// **'Hesabla'**
  String get consActionCalculate;

  /// No description provided for @consActionReverse.
  ///
  /// In az, this message translates to:
  /// **'Storno et'**
  String get consActionReverse;

  /// No description provided for @consActionActivate.
  ///
  /// In az, this message translates to:
  /// **'Aktivləşdir'**
  String get consActionActivate;

  /// No description provided for @consActionNewVersion.
  ///
  /// In az, this message translates to:
  /// **'Yeni versiya'**
  String get consActionNewVersion;

  /// No description provided for @consActionUploadCsv.
  ///
  /// In az, this message translates to:
  /// **'CSV yüklə'**
  String get consActionUploadCsv;

  /// No description provided for @consActionChooseFile.
  ///
  /// In az, this message translates to:
  /// **'Fayl seç'**
  String get consActionChooseFile;

  /// No description provided for @consActionAddComponent.
  ///
  /// In az, this message translates to:
  /// **'Tərkib əlavə et'**
  String get consActionAddComponent;

  /// No description provided for @consActionMapPosCode.
  ///
  /// In az, this message translates to:
  /// **'Menyu maddəsinə bağla'**
  String get consActionMapPosCode;

  /// No description provided for @consEmptySalesReason.
  ///
  /// In az, this message translates to:
  /// **'Bu gün üçün satış daxil edilməyib.'**
  String get consEmptySalesReason;

  /// No description provided for @consEmptySalesNext.
  ///
  /// In az, this message translates to:
  /// **'Menyu maddəsini tapın və satılan sayı yazın.'**
  String get consEmptySalesNext;

  /// No description provided for @consEmptyMenuItemsReason.
  ///
  /// In az, this message translates to:
  /// **'Menyu maddəsi tapılmadı.'**
  String get consEmptyMenuItemsReason;

  /// No description provided for @consEmptyMenuItemsNext.
  ///
  /// In az, this message translates to:
  /// **'Axtarışı dəyişin və ya menecerdən menyu maddəsi yaratmasını istəyin.'**
  String get consEmptyMenuItemsNext;

  /// No description provided for @consEmptyResultReason.
  ///
  /// In az, this message translates to:
  /// **'Bu tarix üçün istehlak sənədi yoxdur.'**
  String get consEmptyResultReason;

  /// No description provided for @consEmptyResultNext.
  ///
  /// In az, this message translates to:
  /// **'Satışı təsdiqləyin — hesablama gecə işləyir, sonra nəticə burada görünür.'**
  String get consEmptyResultNext;

  /// No description provided for @consEmptyRunsReason.
  ///
  /// In az, this message translates to:
  /// **'Seçilmiş filtrə uyğun istehlak sənədi yoxdur.'**
  String get consEmptyRunsReason;

  /// No description provided for @consEmptyRunsNext.
  ///
  /// In az, this message translates to:
  /// **'Tarix aralığını genişləndirin və ya satış importundan yeni sənəd yaradın.'**
  String get consEmptyRunsNext;

  /// No description provided for @consEmptyImportsReason.
  ///
  /// In az, this message translates to:
  /// **'Seçilmiş filtrə uyğun satış importu yoxdur.'**
  String get consEmptyImportsReason;

  /// No description provided for @consEmptyImportsNext.
  ///
  /// In az, this message translates to:
  /// **'CSV yükləyin və ya filial mobil tətbiqdən günün satışını daxil etsin.'**
  String get consEmptyImportsNext;

  /// No description provided for @consEmptyRecipeLinesReason.
  ///
  /// In az, this message translates to:
  /// **'Bu versiyanın tərkibi boşdur.'**
  String get consEmptyRecipeLinesReason;

  /// No description provided for @consEmptyRecipeLinesNext.
  ///
  /// In az, this message translates to:
  /// **'Tərkib əlavə edin — boş resept aktivləşdirilə bilməz.'**
  String get consEmptyRecipeLinesNext;

  /// No description provided for @consEmptyVersionsReason.
  ///
  /// In az, this message translates to:
  /// **'Bu menyu maddəsinin resepti yoxdur.'**
  String get consEmptyVersionsReason;

  /// No description provided for @consEmptyVersionsNext.
  ///
  /// In az, this message translates to:
  /// **'Yeni versiya yaradın, tərkibi doldurun və aktivləşdirin.'**
  String get consEmptyVersionsNext;

  /// No description provided for @consEmptyVarianceReason.
  ///
  /// In az, this message translates to:
  /// **'Seçilmiş dövrdə fərq sətri yoxdur.'**
  String get consEmptyVarianceReason;

  /// No description provided for @consEmptyVarianceNext.
  ///
  /// In az, this message translates to:
  /// **'İki sayım arasındakı dövrü seçin — hesabat sayımdan sayıma işləyir.'**
  String get consEmptyVarianceNext;

  /// No description provided for @consEmptyExplosionReason.
  ///
  /// In az, this message translates to:
  /// **'Partlama nəticəsi boşdur.'**
  String get consEmptyExplosionReason;

  /// No description provided for @consEmptyExplosionNext.
  ///
  /// In az, this message translates to:
  /// **'Tərkib əlavə edib yadda saxlayın, sonra önizləmə yenilənir.'**
  String get consEmptyExplosionNext;

  /// No description provided for @consShortfallTitle.
  ///
  /// In az, this message translates to:
  /// **'Qalıq çatmadı'**
  String get consShortfallTitle;

  /// No description provided for @consShortfallExplained.
  ///
  /// In az, this message translates to:
  /// **'Nəzəri məxaricin bir hissəsi stokdan çıxarıla bilmədi, çünki qalıq tükənmişdi. Çox güman ki, qəbul qeyd olunmayıb — gələn malı yoxlayın.'**
  String get consShortfallExplained;

  /// No description provided for @consUnmappedTitle.
  ///
  /// In az, this message translates to:
  /// **'Resepti olmayan satış'**
  String get consUnmappedTitle;

  /// No description provided for @consUnmappedExplained.
  ///
  /// In az, this message translates to:
  /// **'Bu sətirlər məxaric yaratmadı: menyu maddəsi tanınmadı və ya onun resepti yoxdur.'**
  String get consUnmappedExplained;

  /// No description provided for @consNoRecipeWarning.
  ///
  /// In az, this message translates to:
  /// **'Resepti olmayan menyu maddələri var — onların satışı stokdan heç nə çıxarmır.'**
  String get consNoRecipeWarning;

  /// No description provided for @consAlreadySubmitted.
  ///
  /// In az, this message translates to:
  /// **'Bu günün satışı artıq təsdiqlənib'**
  String get consAlreadySubmitted;

  /// No description provided for @consAlreadySubmittedHint.
  ///
  /// In az, this message translates to:
  /// **'Bir gün üçün bir sənəd olur. Düzəliş lazımdırsa menecerə müraciət edin.'**
  String get consAlreadySubmittedHint;

  /// No description provided for @consReverseReasonRequired.
  ///
  /// In az, this message translates to:
  /// **'Storno üçün səbəb kodu məcburidir'**
  String get consReverseReasonRequired;

  /// No description provided for @consReverseTitle.
  ///
  /// In az, this message translates to:
  /// **'İstehlakı storno et'**
  String get consReverseTitle;

  /// No description provided for @consReverseMessage.
  ///
  /// In az, this message translates to:
  /// **'Post edilmiş sənəd redaktə olunmur. Storno yeni hərəkət qrupu yaradır və həmin gün üçün yenidən hesablamağa imkan verir.'**
  String get consReverseMessage;

  /// No description provided for @consYieldHint.
  ///
  /// In az, this message translates to:
  /// **'Emal itkisi: 92 yazsanız stokdan qeyd olunandan çox çıxır.'**
  String get consYieldHint;

  /// No description provided for @consPreviewPending.
  ///
  /// In az, this message translates to:
  /// **'Yadda saxlanmamış dəyişikliklər var — aşağıdakı rəqəmlər yerli hesablamadır.'**
  String get consPreviewPending;

  /// No description provided for @consPreviewServer.
  ///
  /// In az, this message translates to:
  /// **'Server partlaması'**
  String get consPreviewServer;

  /// No description provided for @consSubRecipeNeedsSave.
  ///
  /// In az, this message translates to:
  /// **'Alt-resept yalnız yadda saxlandıqdan sonra açılır.'**
  String get consSubRecipeNeedsSave;

  /// No description provided for @consErrRecipeCycle.
  ///
  /// In az, this message translates to:
  /// **'Alt-reseptlər dövrə yaradır (A → B → A). Tərkibdəki alt-resepti dəyişin.'**
  String get consErrRecipeCycle;

  /// No description provided for @consErrRecipeDepth.
  ///
  /// In az, this message translates to:
  /// **'Alt-resept dərinliyi 5-dən çoxdur. Zənciri qısaldın.'**
  String get consErrRecipeDepth;

  /// No description provided for @consErrRecipeEmpty.
  ///
  /// In az, this message translates to:
  /// **'Tərkibi boş resept aktivləşdirilə bilməz. Ən azı bir sətir əlavə edin.'**
  String get consErrRecipeEmpty;

  /// No description provided for @consErrPeriodClosed.
  ///
  /// In az, this message translates to:
  /// **'Bu tarixdən əvvəl post edilmiş istehlak sənədi var. Daha sonrakı tarix seçin.'**
  String get consErrPeriodClosed;

  /// No description provided for @consErrDuplicateBusinessDate.
  ///
  /// In az, this message translates to:
  /// **'Bu filial və gün üçün sənəd artıq mövcuddur. Mövcud sənədi açın.'**
  String get consErrDuplicateBusinessDate;

  /// No description provided for @consErrUomFactorMissing.
  ///
  /// In az, this message translates to:
  /// **'Bu tarix üçün vahid çevirmə əmsalı yoxdur. Master Data-da vahidi yoxlayın.'**
  String get consErrUomFactorMissing;

  /// No description provided for @consErrFileTooLarge.
  ///
  /// In az, this message translates to:
  /// **'Fayl 5 MB-dan böyükdür. Hesabatı bölüb yükləyin.'**
  String get consErrFileTooLarge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['az', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'az':
      return AppLocalizationsAz();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
