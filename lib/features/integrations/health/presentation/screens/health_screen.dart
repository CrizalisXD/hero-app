import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../../../../core/widgets/hero_card.dart';
import '../../../../settings/data/user_consents_repository.dart';
import '../../application/health_connection_notifier.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    // Record consent BEFORE asking the OS for permission — TZ §15
    // critical rule: never request health permission without consent on file.
    await ref
        .read(userConsentsRepoProvider)
        .setConsent(ConsentKeys.integrationHealthRead, true);

    final ok = await ref.read(healthConnectionProvider.notifier).connect();
    if (!ok) {
      // Permission denied — revoke the pre-recorded consent so the ledger
      // doesn't claim access that was never actually granted.
      await ref
          .read(userConsentsRepoProvider)
          .setConsent(ConsentKeys.integrationHealthRead, false);
    }
    if (!context.mounted) return;
    final l = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l.healthSyncSuccess : l.healthPermissionDenied),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(healthConnectionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.healthScreenTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l.healthConnectTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              l.healthConnectBody,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _StatusCard(state: s),
            const SizedBox(height: 24),
            if (!s.connected)
              HeroButton(
                label: l.healthConnectButton,
                isLoading: s.busy,
                onPressed: s.busy ? null : () => _connect(context, ref),
              )
            else ...[
              HeroButton(
                label: l.healthSyncNow,
                onPressed: s.busy
                    ? null
                    : () => ref
                        .read(healthConnectionProvider.notifier)
                        .syncNow(),
              ),
              const SizedBox(height: 8),
              HeroButton(
                label: l.healthDisconnectButton,
                variant: HeroButtonVariant.secondary,
                onPressed: s.busy
                    ? null
                    : () => ref
                        .read(healthConnectionProvider.notifier)
                        .disconnect(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});
  final HealthConnectionState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return HeroCard(
      borderColor: state.connected ? AppColors.success : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.connected ? Icons.check_circle : Icons.cloud_off,
                color: state.connected
                    ? AppColors.success
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                state.connected
                    ? l.healthStatusConnected
                    : l.healthStatusNotConnected,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (state.connected) ...[
            const SizedBox(height: 10),
            Text(l.healthTodaySteps(state.today.steps)),
            Text(
              l.healthTodayDistance(
                (state.today.distanceMeters / 1000).toStringAsFixed(1),
              ),
            ),
            if (state.today.lastSyncAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.healthLastSync(
                    DateFormat.Hm().format(state.today.lastSyncAt!.toLocal()),
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
