// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitleMobile => 'WMS Склад';

  @override
  String get appTitleWeb => 'WMS Закупки и склад';

  @override
  String get navWarehouse => 'Склад';

  @override
  String get navDocuments => 'Документы';

  @override
  String get navProcurement => 'Закупки';

  @override
  String get navMasterData => 'Справочники';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navNotifications => 'Уведомления';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navDashboard => 'Панель';

  @override
  String get navAdmin => 'Админ';

  @override
  String get docReceipt => 'Приёмка';

  @override
  String get docIssue => 'Отпуск';

  @override
  String get docTransfer => 'Перемещение';

  @override
  String get docCount => 'Инвентаризация';

  @override
  String get docWaste => 'Списание';

  @override
  String get docSample => 'Проба';

  @override
  String get docStockRequest => 'Заявка на склад';

  @override
  String get docRequisition => 'PR';

  @override
  String get docRequisitionLong => 'Заявка на закупку (PR)';

  @override
  String get docPurchaseOrder => 'PO';

  @override
  String get docPurchaseOrderLong => 'Заказ поставщику (PO)';

  @override
  String get docRfq => 'RFQ';

  @override
  String get docQuotation => 'Предложение';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionCreate => 'Создать';

  @override
  String get actionPost => 'Провести';

  @override
  String get actionApprove => 'Утвердить';

  @override
  String get actionReject => 'Отклонить';

  @override
  String get actionConfirmReceipt => 'Подтвердить получение';

  @override
  String get actionDispatch => 'Отправить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionLogin => 'Войти';

  @override
  String get actionLogout => 'Выйти';

  @override
  String get actionScan => 'Сканировать штрихкод';

  @override
  String get actionExport => 'Экспорт в Excel';

  @override
  String get actionSearch => 'Поиск';

  @override
  String get actionAddLine => 'Добавить строку';

  @override
  String get actionSelect => 'Выбрать';

  @override
  String get labelBalances => 'Остатки';

  @override
  String get labelProducts => 'Товары';

  @override
  String get labelSuppliers => 'Поставщики';

  @override
  String get labelLocations => 'Локации';

  @override
  String get labelUoms => 'Единицы измерения';

  @override
  String get labelPriceHistory => 'История цен';

  @override
  String get labelComparison => 'Сравнение предложений';

  @override
  String get labelUsers => 'Пользователи';

  @override
  String get labelRoles => 'Роли';

  @override
  String get labelSettings => 'Настройки';

  @override
  String get labelStatus => 'Статус';

  @override
  String get labelDate => 'Дата';

  @override
  String get labelQuantity => 'Количество';

  @override
  String get labelProduct => 'Товар';

  @override
  String get labelLocation => 'Локация';

  @override
  String get labelSupplier => 'Поставщик';

  @override
  String get labelReasonCode => 'Код причины';

  @override
  String get labelNote => 'Примечание';

  @override
  String get labelVarianceNote => 'Примечание о расхождении';

  @override
  String get labelSelectionNote => 'Обоснование выбора';

  @override
  String get labelBatchNo => 'Номер партии';

  @override
  String get labelExpiryDate => 'Срок годности';

  @override
  String get labelOrdered => 'Заказано';

  @override
  String get labelReceived => 'Принято';

  @override
  String get labelBook => 'Учётный остаток';

  @override
  String get labelCounted => 'Подсчитано';

  @override
  String get labelVariance => 'Расхождение';

  @override
  String get labelPhoto => 'Фото';

  @override
  String get labelUnread => 'Непрочитанные';

  @override
  String get labelAll => 'Все';

  @override
  String get labelLoading => 'Загрузка…';

  @override
  String get labelNoPermission => 'У вас нет прав на это действие';

  @override
  String labelSignedInAs(String name) {
    return 'Вы вошли как $name';
  }

  @override
  String labelUnreadCount(int count) {
    return 'Непрочитанных уведомлений: $count';
  }

  @override
  String get errorGeneric => 'Произошла ошибка';

  @override
  String get errorNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get validationRequired => 'Обязательное поле';

  @override
  String get validationVarianceNoteRequired =>
      'Количество отличается от заказа — требуется примечание о расхождении';

  @override
  String get validationReasonCodeRequired =>
      'Расхождение не равно нулю — требуется код причины';

  @override
  String get validationSelectionNoteRequired =>
      'Выбрано не самое дешёвое предложение — требуется обоснование';

  @override
  String get validationNegativeQty => 'Количество не может быть отрицательным';

  @override
  String get emptyBalances =>
      'На этой локации нет остатков. Создайте документ приёмки.';

  @override
  String get emptyDocuments => 'Документов пока нет. Создайте новый документ.';

  @override
  String get emptyNotifications => 'Непрочитанных уведомлений нет.';

  @override
  String get loginSubtitle =>
      'Войдите с корпоративной учётной записью, чтобы продолжить';

  @override
  String get loginFailed => 'Не удалось войти';

  @override
  String get navConsumption => 'Потребление';

  @override
  String get navBranch => 'Филиал';

  @override
  String get consDailySales => 'Продажи за день';

  @override
  String get consResult => 'Результат потребления';

  @override
  String get consRecipeCatalog => 'Каталог рецептов';

  @override
  String get consRecipeEditor => 'Редактор рецепта';

  @override
  String get consSalesImport => 'Импорт продаж';

  @override
  String get consJournal => 'Журнал потребления';

  @override
  String get consVarianceReport => 'Отчёт о расхождениях';

  @override
  String get consLabelMenuItem => 'Позиция меню';

  @override
  String get consLabelSold => 'Продано';

  @override
  String get consLabelBusinessDate => 'Рабочий день';

  @override
  String get consLabelTheoretical => 'Теоретически';

  @override
  String get consLabelPosted => 'Списано';

  @override
  String get consLabelShortfall => 'Нехватка';

  @override
  String get consLabelYieldPct => 'Выход, %';

  @override
  String get consLabelAttachRatePct => 'Доля добавления, %';

  @override
  String get consLabelQtyPerPortion => 'На порцию';

  @override
  String get consLabelComponent => 'Компонент';

  @override
  String get consLabelComponentType => 'Тип компонента';

  @override
  String get consLabelOptional => 'Опционально';

  @override
  String get consLabelValidFrom => 'Действует с';

  @override
  String get consLabelValidTo => 'Действует по';

  @override
  String get consLabelVersion => 'Версия';

  @override
  String get consLabelPortions => 'Порции';

  @override
  String get consLabelExplosion => 'Разузлование BOM';

  @override
  String get consLabelUnmapped => 'Не распознано';

  @override
  String get consLabelTotalSold => 'Всего продано';

  @override
  String get consLabelSource => 'Источник';

  @override
  String get consLabelPosCode => 'Код POS';

  @override
  String get consLabelColumnMapping => 'Сопоставление столбцов';

  @override
  String get consLabelParseErrors => 'Нечитаемые строки';

  @override
  String get consLabelRow => 'Строка';

  @override
  String get consLabelExpected => 'Ожидаемо';

  @override
  String get consLabelOpening => 'На начало периода';

  @override
  String get consLabelPeriodFrom => 'Начало периода';

  @override
  String get consLabelPeriodTo => 'Конец периода';

  @override
  String get consLabelCompliancePct => 'Соответствие, %';

  @override
  String get consLabelRecipeMissing => 'Нет рецепта';

  @override
  String get consLabelSubRecipe => 'Полуфабрикат';

  @override
  String get consLabelFoodProduct => 'Складской товар';

  @override
  String get consLabelLineCount => 'Строк';

  @override
  String get consLabelDocNo => 'Документ';

  @override
  String get consLabelFile => 'Файл';

  @override
  String get consActionSubmitSales => 'Подтвердить продажи';

  @override
  String get consActionCalculate => 'Рассчитать';

  @override
  String get consActionReverse => 'Сторнировать';

  @override
  String get consActionActivate => 'Активировать';

  @override
  String get consActionNewVersion => 'Новая версия';

  @override
  String get consActionUploadCsv => 'Загрузить CSV';

  @override
  String get consActionChooseFile => 'Выбрать файл';

  @override
  String get consActionAddComponent => 'Добавить компонент';

  @override
  String get consActionMapPosCode => 'Привязать к позиции меню';

  @override
  String get consEmptySalesReason => 'Продажи за этот день не введены.';

  @override
  String get consEmptySalesNext =>
      'Найдите позицию меню и укажите проданное количество.';

  @override
  String get consEmptyMenuItemsReason => 'Позиция меню не найдена.';

  @override
  String get consEmptyMenuItemsNext =>
      'Измените поиск или попросите менеджера создать позицию меню.';

  @override
  String get consEmptyResultReason => 'За эту дату нет документа потребления.';

  @override
  String get consEmptyResultNext =>
      'Подтвердите продажи — расчёт выполняется ночью, затем результат появится здесь.';

  @override
  String get consEmptyRunsReason =>
      'По выбранному фильтру нет документов потребления.';

  @override
  String get consEmptyRunsNext =>
      'Расширьте диапазон дат или создайте документ из импорта продаж.';

  @override
  String get consEmptyImportsReason =>
      'По выбранному фильтру нет импортов продаж.';

  @override
  String get consEmptyImportsNext =>
      'Загрузите CSV или попросите филиал ввести продажи в мобильном приложении.';

  @override
  String get consEmptyRecipeLinesReason => 'В этой версии нет состава.';

  @override
  String get consEmptyRecipeLinesNext =>
      'Добавьте компонент — пустой рецепт активировать нельзя.';

  @override
  String get consEmptyVersionsReason => 'У этой позиции меню нет рецепта.';

  @override
  String get consEmptyVersionsNext =>
      'Создайте версию, заполните состав и активируйте её.';

  @override
  String get consEmptyVarianceReason =>
      'За выбранный период нет строк расхождений.';

  @override
  String get consEmptyVarianceNext =>
      'Выберите период между двумя инвентаризациями — отчёт работает от счёта к счёту.';

  @override
  String get consEmptyExplosionReason => 'Результат разузлования пуст.';

  @override
  String get consEmptyExplosionNext =>
      'Добавьте состав и сохраните — предпросмотр обновится.';

  @override
  String get consShortfallTitle => 'Остатка не хватило';

  @override
  String get consShortfallExplained =>
      'Часть теоретического расхода не удалось списать: остаток был исчерпан. Скорее всего, приход не зарегистрирован — проверьте поступления.';

  @override
  String get consUnmappedTitle => 'Продажи без рецепта';

  @override
  String get consUnmappedExplained =>
      'Эти строки не создали расход: позиция меню не распознана или у неё нет рецепта.';

  @override
  String get consNoRecipeWarning =>
      'Есть позиции меню без рецепта — их продажи ничего не списывают со склада.';

  @override
  String get consAlreadySubmitted => 'Продажи за этот день уже подтверждены';

  @override
  String get consAlreadySubmittedHint =>
      'Один документ на день. Для исправления обратитесь к менеджеру.';

  @override
  String get consReverseReasonRequired => 'Для сторно обязателен код причины';

  @override
  String get consReverseTitle => 'Сторнировать потребление';

  @override
  String get consReverseMessage =>
      'Проведённый документ не редактируется. Сторно создаёт новую группу движений и освобождает день для нового расчёта.';

  @override
  String get consYieldHint =>
      'Потери при обработке: если указать 92, со склада уйдёт больше, чем записано в рецепте.';

  @override
  String get consPreviewPending =>
      'Есть несохранённые изменения — цифры ниже рассчитаны локально.';

  @override
  String get consPreviewServer => 'Разузлование на сервере';

  @override
  String get consSubRecipeNeedsSave =>
      'Полуфабрикат разузловывается только после сохранения черновика.';

  @override
  String get consErrRecipeCycle =>
      'Полуфабрикаты образуют цикл (A → B → A). Измените компонент-полуфабрикат.';

  @override
  String get consErrRecipeDepth =>
      'Глубина вложенности полуфабрикатов больше 5. Сократите цепочку.';

  @override
  String get consErrRecipeEmpty =>
      'Рецепт без состава активировать нельзя. Добавьте хотя бы одну строку.';

  @override
  String get consErrPeriodClosed =>
      'До этой даты уже есть проведённый документ потребления. Выберите более позднюю дату.';

  @override
  String get consErrDuplicateBusinessDate =>
      'Документ для этого филиала и дня уже существует. Откройте существующий.';

  @override
  String get consErrUomFactorMissing =>
      'На эту дату нет коэффициента пересчёта единиц. Проверьте единицу в Master Data.';

  @override
  String get consErrFileTooLarge =>
      'Файл больше 5 МБ. Разделите отчёт и загрузите снова.';
}
