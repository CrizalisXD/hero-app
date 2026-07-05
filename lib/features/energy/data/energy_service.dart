import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

/// Catalog of energy costs for every "create" action in the app.
///
/// Centralised so the UI and tests have one source of truth, and so a
/// future remote-flag-driven tuning pass can replace these without
/// touching the call sites.
class EnergyCosts {
  EnergyCosts._();

  static const int taskEasy = 10;
  static const int taskNormal = 20;
  static const int taskHard = 35;
  static const int taskEpic = 50;

  static const int habitGood = 25;
  static const int habitBad = 20;

  static const int goal = 50;

  /// Picks the right task cost from the wire string written by
  /// CreateTaskInput / Task.toJson. Falls back to "normal" cost if the
  /// value is unknown so we never block a legitimate create on a typo.
  static int forTaskDifficulty(String? wire) {
    switch (wire) {
      case 'easy':
        return taskEasy;
      case 'hard':
        return taskHard;
      case 'epic':
        return taskEpic;
      case 'normal':
      default:
        return taskNormal;
    }
  }
}

class EnergySpendResult {
  const EnergySpendResult({
    required this.ok,
    required this.energy,
    required this.max,
    this.needed,
  });

  final bool ok;
  final int energy;
  final int max;

  /// Only present when ok=false — useful to surface the deficit in UI.
  final int? needed;

  factory EnergySpendResult.fromJson(Map<String, dynamic> j) {
    return EnergySpendResult(
      ok: j['ok'] == true,
      energy: (j['energy'] as num?)?.toInt() ?? 0,
      max: (j['max'] as num?)?.toInt() ?? 100,
      needed: (j['needed'] as num?)?.toInt(),
    );
  }
}

class EnergyRegenResult {
  const EnergyRegenResult({
    required this.energy,
    required this.max,
    required this.added,
    required this.dailyBonus,
  });

  final int energy;
  final int max;
  final int added;
  final int dailyBonus;

  factory EnergyRegenResult.fromJson(Map<String, dynamic> j) {
    return EnergyRegenResult(
      energy: (j['energy'] as num?)?.toInt() ?? 0,
      max: (j['max'] as num?)?.toInt() ?? 100,
      added: (j['added'] as num?)?.toInt() ?? 0,
      dailyBonus: (j['daily_bonus'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Thin wrapper over the spend_energy / regen_energy RPCs.
class EnergyService {
  EnergyService(this._client);
  final SupabaseClient _client;

  /// Idempotent within the hour. Call once on app foreground / Home
  /// load to apply passive regen + daily login bonus and refresh the
  /// cap from current Endurance level.
  Future<EnergyRegenResult?> regen() async {
    try {
      final raw =
          await _client.rpc<dynamic>('regen_energy') as Map<String, dynamic>?;
      if (raw == null) return null;
      return EnergyRegenResult.fromJson(raw);
    } catch (e) {
      debugPrint('regen_energy err: $e');
      return null;
    }
  }

  /// Atomic spend. Throws PostgrestException on server errors (including
  /// an unexpected payload shape); returns EnergySpendResult.ok=false when
  /// the user simply doesn't have enough. The caller decides how to
  /// surface that to the UI.
  Future<EnergySpendResult> spend(int amount) async {
    final raw = await _client.rpc<dynamic>(
      'spend_energy',
      params: {'p_amount': amount},
    );
    if (raw is! Map) {
      // A malformed payload must NOT escape as a CastError — EnergyGuard
      // fails open on unknown errors, which would make creates free.
      throw PostgrestException(
        message: 'spend_energy returned unexpected payload: $raw',
      );
    }
    return EnergySpendResult.fromJson(Map<String, dynamic>.from(raw));
  }
}

final energyServiceProvider = Provider<EnergyService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EnergyService(client);
});
