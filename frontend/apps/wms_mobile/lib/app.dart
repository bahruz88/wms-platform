import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'config/flavors.dart';
import 'router/app_router.dart';

/// Root widget: router, theme and localizations (default locale `az`).
class WmsMobileApp extends ConsumerWidget {
  const WmsMobileApp({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: config.flavor.appTitle,
      debugShowCheckedModeBanner: false,
      theme: WmsTheme.light(),
      darkTheme: WmsTheme.dark(),
      locale: WmsL10n.defaultLocale,
      supportedLocales: WmsL10n.supportedLocales,
      localizationsDelegates: WmsL10n.delegates,
      routerConfig: router,
    );
  }
}
