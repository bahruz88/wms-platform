import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import '../../domain/barcode_scanner.dart';
import '../inventory_providers.dart';

/// Barcode entry point: uses the app-provided [BarcodeScanner] when the
/// platform has one, and always offers manual entry as a fallback.
class BarcodeEntryScreen extends ConsumerStatefulWidget {
  const BarcodeEntryScreen({this.onResolved, super.key});

  /// Called with the resolved product id.
  final ValueChanged<int>? onResolved;

  @override
  ConsumerState<BarcodeEntryScreen> createState() => _BarcodeEntryScreenState();
}

class _BarcodeEntryScreenState extends ConsumerState<BarcodeEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  Failure? _failure;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup(String barcode) async {
    if (barcode.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await ref
        .read(masterDataRepositoryProvider)
        .productByBarcode(barcode.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold((product) {
      ref.read(balanceFilterProvider.notifier).setProduct(product.id);
      widget.onResolved?.call(product.id);
    }, (failure) => setState(() => _failure = failure));
  }

  Future<void> _scan() async {
    final scanner = ref.read(barcodeScannerProvider);
    final code = await scanner.scan();
    if (code != null) {
      _controller.text = code;
      await _lookup(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final scanner = ref.watch(barcodeScannerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.actionScan)),
      body: WmsLoadingOverlay(
        loading: _busy,
        child: ListView(
          padding: const EdgeInsets.all(WmsSpacing.space4),
          children: [
            if (!scanner.isAvailable)
              const WmsAlert(
                title: 'Bu cihazda kamera ilə skan mövcud deyil',
                message: 'Barkodu əl ilə daxil edin.',
              ),
            if (_failure != null) ...[
              const SizedBox(height: WmsSpacing.space3),
              WmsAlert.fromFailure(_failure!),
            ],
            const SizedBox(height: WmsSpacing.space4),
            WmsTextField(
              controller: _controller,
              label: 'Barkod',
              mono: true,
              placeholder: '4600000000000',
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _lookup,
            ),
            const SizedBox(height: WmsSpacing.space4),
            Row(
              children: [
                if (scanner.isAvailable) ...[
                  WmsButton(
                    label: l10n.actionScan,
                    iconLeft: Icons.qr_code_scanner_outlined,
                    onPressed: _scan,
                  ),
                  const SizedBox(width: WmsSpacing.space2),
                ],
                WmsButton.primary(
                  label: l10n.actionSearch,
                  onPressed: () => _lookup(_controller.text),
                ),
              ],
            ),
            const SizedBox(height: WmsSpacing.space4),
            Text(
              'Tapılan məhsul qalıq ekranında filtr kimi tətbiq olunur.',
              style: WmsTypography.caption.copyWith(color: c.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
