import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

import 'identity_providers.dart';

/// Profile: who is signed in, for which tenant, with which roles,
/// permissions and locations — plus sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = WmsColors.of(context);
    final session = ref.watch(sessionProvider);
    final user = ref.watch(currentUserProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navProfile)),
        body: const WmsEmptyState(
          reason: 'Sessiya tapılmadı.',
          nextStep: 'Yenidən daxil olun.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(WmsSpacing.space4),
        children: [
          Text(
            session.displayName,
            style: WmsTypography.titleLg.copyWith(color: c.ink),
          ),
          const SizedBox(height: WmsSpacing.space1),
          Text(
            l10n.labelSignedInAs(session.username),
            style: WmsTypography.caption.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: WmsSpacing.space4),
          _Section(
            title: 'Tenant',
            child: Text(
              '#${session.tenantId}',
              style: WmsTypography.docNo.copyWith(color: c.ink),
            ),
          ),
          _Section(
            title: 'Rollar',
            child: Wrap(
              spacing: WmsSpacing.space2,
              runSpacing: WmsSpacing.space1,
              children: [
                for (final role in session.roles)
                  WmsBadge(text: role, variant: WmsBadgeVariant.outline),
              ],
            ),
          ),
          _Section(
            title: 'İcazələr',
            child: user.when(
              loading: () => Text(
                l10n.labelLoading,
                style: WmsTypography.caption.copyWith(color: c.inkMuted),
              ),
              error: (error, _) => WmsAlert.fromFailure(
                error is AppException
                    ? error.failure
                    : UnexpectedFailure(message: '$error'),
              ),
              data: (data) {
                final permissions =
                    data?.permissions ?? session.permissions.toList();
                if (permissions.isEmpty) {
                  return Text(
                    'İcazə siyahısı boşdur.',
                    style: WmsTypography.caption.copyWith(color: c.inkMuted),
                  );
                }
                return Wrap(
                  spacing: WmsSpacing.space2,
                  runSpacing: WmsSpacing.space1,
                  children: [
                    for (final code in permissions)
                      WmsBadge(
                        text: code,
                        tone: code == Permissions.productViewCost
                            ? WmsTone.accent
                            : WmsTone.neutral,
                      ),
                  ],
                );
              },
            ),
          ),
          if (session.locationIds.isNotEmpty)
            _Section(
              title: 'Lokasiyalar',
              child: Text(
                session.locationIds.join(', '),
                style: WmsTypography.figureSm.copyWith(color: c.ink),
              ),
            ),
          const SizedBox(height: WmsSpacing.space5),
          WmsButton(
            label: l10n.actionLogout,
            iconLeft: Icons.logout_outlined,
            onPressed: () =>
                ref.read(loginControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = WmsColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: WmsSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: WmsTypography.label.copyWith(color: c.inkMuted)),
          const SizedBox(height: WmsSpacing.space1),
          child,
        ],
      ),
    );
  }
}
