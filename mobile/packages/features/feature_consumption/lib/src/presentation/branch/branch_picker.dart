import 'package:feature_master_data/feature_master_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_design_system/wms_design_system.dart';

import '../consumption_providers.dart';

/// Asks which branch the screen is about, for an account that is not pinned to
/// exactly one.
///
/// That is the normal case for an administrator or a manager: the contract says
/// an empty `locationIds` means *no restriction*, so those accounts see every
/// branch and have to say which one they are entering sales for. The branch
/// screens used to read the same empty list as "no branch assigned" and told
/// them to ask an administrator for access they already had.
class BranchPicker extends ConsumerWidget {
  const BranchPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = WmsColors.of(context);
    final locations = ref.watch(locationListProvider);
    final allowed = ref.watch(sessionProvider)?.locationIds ?? const <int>[];
    final chosen = ref.watch(chosenBranchLocationIdProvider);

    return Padding(
      padding: const EdgeInsets.all(WmsSpacing.space4),
      child: AsyncView<List<LocationDto>>(
        value: locations,
        onRetry: () => ref.invalidate(locationListProvider),
        builder: (all) {
          // An empty `locationIds` is no restriction, so every branch is on the
          // list; otherwise only the ones the account carries.
          final branches = all
              .where(
                (l) =>
                    !l.isVirtual &&
                    l.isActive &&
                    (allowed.isEmpty || allowed.contains(l.id)),
              )
              .toList();
          if (branches.isEmpty) {
            return const WmsEmptyState(
              reason: 'Görünən filial yoxdur.',
              nextStep: 'Administratordan lokasiya bağlanmasını istəyin.',
              icon: Icons.store_outlined,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hansı filial üçün?',
                style: WmsTypography.title.copyWith(color: c.ink),
              ),
              const SizedBox(height: WmsSpacing.space2),
              Text(
                'Hesabınız bir neçə filiala baxa bilir, ona görə seçim lazımdır.',
                style: WmsTypography.body.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: WmsSpacing.space4),
              WmsSelect<int>(
                label: 'Filial',
                required: true,
                value: chosen,
                placeholder: 'Filial seçin',
                options: [
                  for (final branch in branches)
                    WmsSelectOption(
                      value: branch.id,
                      label: '${branch.code} · ${branch.name}',
                    ),
                ],
                onChanged: (value) => ref
                    .read(chosenBranchLocationIdProvider.notifier)
                    .choose(value),
              ),
            ],
          );
        },
      ),
    );
  }
}
