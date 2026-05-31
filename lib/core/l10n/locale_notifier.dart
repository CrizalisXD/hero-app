import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/supabase_service.dart';

part 'locale_notifier.g.dart';

const supportedLocales = [Locale('ru'), Locale('en')];

/// Source-of-truth for the app locale.
///
/// Resolution order:
///   1) `public.users.locale` — if the row exists, that wins.
///   2) System locale — if `ru` use 'ru', otherwise default to 'en'.
///
/// Writing `setLocale('ru'|'en')` updates UI immediately (optimistic)
/// then persists to `users.locale`. On DB failure → rollback to previous.
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Future<Locale> build() async {
    final client = ref.read(supabaseClientProvider);

    // (1) DB
    try {
      final row = await client.from('users').select('locale').single();
      final raw = row['locale'] as String?;
      if (raw == 'ru' || raw == 'en') return Locale(raw!);
    } catch (_) {
      // No row yet (pre-bootstrap) or RLS denied — fall through.
    }

    // (2) System fallback
    final system =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (system == 'ru') return const Locale('ru');
    return const Locale('en');
  }

  Future<bool> setLocale(String code) async {
    if (code != 'ru' && code != 'en') return false;

    final previous = state;
    state = AsyncData(Locale(code));

    try {
      final client = ref.read(supabaseClientProvider);
      final uid = client.auth.currentUser?.id;
      if (uid == null) {
        // No user yet — only in-memory change, no DB write.
        return true;
      }
      await client.from('users').update({'locale': code}).eq('id', uid);
      return true;
    } catch (_) {
      state = previous;
      return false;
    }
  }
}
