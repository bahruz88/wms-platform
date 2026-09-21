import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_l10n/wms_l10n.dart';

void main() {
  test('az is the template locale and every locale loads', () async {
    expect(WmsL10n.supportedLocales.first, const Locale('az'));
    final az = await AppLocalizations.delegate.load(const Locale('az'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ru = await AppLocalizations.delegate.load(const Locale('ru'));
    expect(az.navWarehouse, 'Anbar');
    expect(az.docReceipt, 'Qəbul');
    expect(az.labelSignedInAs('keeper'), 'keeper kimi daxil olmusunuz');
    expect(en.navProcurement, 'Procurement');
    expect(ru.navReports, 'Отчёты');
  });

  test('resolve falls back to az', () {
    expect(
      WmsL10n.resolve([const Locale('de')], WmsL10n.supportedLocales),
      const Locale('az'),
    );
    expect(
      WmsL10n.resolve([const Locale('ru', 'RU')], WmsL10n.supportedLocales),
      const Locale('ru'),
    );
  });

  test('no uppercase-transformed labels (i/İ rule)', () async {
    final az = await AppLocalizations.delegate.load(const Locale('az'));
    for (final text in [az.navWarehouse, az.navProcurement, az.actionPost]) {
      expect(text, isNot(equals(text.toUpperCase())));
    }
  });
}
