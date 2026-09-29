import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';

/// Renders an [AsyncValue] with the design system's loading/error surfaces:
/// server problems go through `WmsAlert` so the RFC 7807 `code` stays
/// visible, never a bare exception string.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.value,
    required this.builder,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  static Failure failureOf(Object error) => error is AppException
      ? error.failure
      : UnexpectedFailure(message: '$error', error: error);

  @override
  Widget build(BuildContext context) => value.when(
    data: builder,
    loading: () => const Center(
      child: Padding(
        padding: EdgeInsets.all(WmsSpacing.space6),
        child: WmsSpinner(size: 20),
      ),
    ),
    // Scrollable: a server problem can carry a long `detail`, and a failure the
    // client did not expect carries the exception's own text. Laid out flat,
    // anything taller than the screen overflows — the reader sees a striped bar
    // instead of the reason, which is the one thing the screen exists to show.
    error: (error, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(WmsSpacing.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WmsAlert.fromFailure(failureOf(error)),
          if (onRetry != null) ...[
            const SizedBox(height: WmsSpacing.space3),
            Align(
              alignment: Alignment.centerLeft,
              child: WmsButton(
                label: 'Yenidən cəhd et',
                iconLeft: Icons.refresh_outlined,
                onPressed: onRetry,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
