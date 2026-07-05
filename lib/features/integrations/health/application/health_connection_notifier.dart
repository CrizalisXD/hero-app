import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/health_native_service.dart';
import '../data/supabase_health_repository.dart';
import 'health_sync_service.dart';

part 'health_connection_notifier.g.dart';

class HealthConnectionState {
  const HealthConnectionState({
    required this.connected,
    required this.today,
    this.busy = false,
  });

  final bool connected;
  final TodayHealth today;
  final bool busy;

  HealthConnectionState copyWith({
    bool? connected,
    TodayHealth? today,
    bool? busy,
  }) {
    return HealthConnectionState(
      connected: connected ?? this.connected,
      today: today ?? this.today,
      busy: busy ?? this.busy,
    );
  }

  static const empty = HealthConnectionState(
    connected: false,
    today: TodayHealth(steps: 0, distanceMeters: 0, workoutsCount: 0),
  );
}

@Riverpod(keepAlive: true)
class HealthConnection extends _$HealthConnection {
  @override
  Future<HealthConnectionState> build() async {
    final connected = await HealthNativeService.instance.hasPermissions();
    final today =
        await ref.read(supabaseHealthRepositoryProvider).getToday();
    return HealthConnectionState(connected: connected, today: today);
  }

  /// Requests HealthKit / Health Connect access and runs a first sync.
  /// Returns whether permission was GRANTED — "connected" tracks the
  /// grant, not the first sync result: an empty or transiently failing
  /// first sync must not present as "not connected" and re-prompt.
  Future<bool> connect() async {
    final current = state.value ?? HealthConnectionState.empty;
    state = AsyncData(current.copyWith(busy: true));

    final granted =
        await HealthNativeService.instance.requestPermissions();
    if (!granted) {
      state = AsyncData(current.copyWith(busy: false, connected: false));
      return false;
    }

    await ref.read(healthSyncServiceProvider).syncRecent(days: 7);
    final today =
        await ref.read(supabaseHealthRepositoryProvider).getToday();
    state = AsyncData(
      HealthConnectionState(connected: true, today: today),
    );
    return true;
  }

  Future<void> syncNow() async {
    final s = state.value;
    if (s == null || s.busy) return;
    state = AsyncData(s.copyWith(busy: true));
    await ref.read(healthSyncServiceProvider).syncRecent(days: 7);
    final today =
        await ref.read(supabaseHealthRepositoryProvider).getToday();
    final cur = state.value ?? s;
    state = AsyncData(cur.copyWith(today: today, busy: false));
  }

  Future<void> disconnect() async {
    final s = state.value;
    if (s == null) return;
    final provider = HealthNativeService.instance.providerKey;
    await ref
        .read(supabaseHealthRepositoryProvider)
        .disconnect(provider);
    state = AsyncData(s.copyWith(connected: false));
  }
}
