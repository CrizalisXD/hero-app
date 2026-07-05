import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../data/energy_service.dart';

/// Try to spend [amount] energy. On success returns true. On failure
/// shows a "not enough energy" dialog and returns false.
///
/// Call this BEFORE creating a task / habit / goal. The flow stays:
///   final ok = await EnergyGuard.spendOrBlock(context, ref, EnergyCosts.taskNormal);
///   if (!ok) return;
///   // ... do the actual insert
class EnergyGuard {
  EnergyGuard._();

  static Future<bool> spendOrBlock(
    BuildContext context,
    WidgetRef ref,
    int amount,
  ) async {
    try {
      final res = await ref.read(energyServiceProvider).spend(amount);
      if (res.ok) return true;
      if (!context.mounted) return false;
      await _showNotEnoughDialog(context, res.energy, res.needed ?? amount);
      return false;
    } on PostgrestException catch (e) {
      // The server answered and errored/refused — fail CLOSED. Failing
      // open here would hand out unlimited free creates for as long as
      // the spend_energy RPC is broken (bad migration, RLS change, …),
      // and energy is NOT re-checked server-side.
      debugPrint('energy spend rejected: ${e.message}');
      return false;
    } catch (e) {
      // Transport-level failure (offline, timeout) — let the action
      // through rather than blocking the user behind a network hiccup.
      debugPrint('energy spend infra err: $e');
      return true;
    }
  }

  static Future<void> _showNotEnoughDialog(
    BuildContext context,
    int have,
    int needed,
  ) {
    final l = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.bolt, color: AppColors.warning, size: 32),
        title: Text(l.energyNotEnoughTitle),
        content: Text(l.energyNotEnoughBody(have, needed)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.commonCancel),
          ),
        ],
      ),
    );
  }
}
