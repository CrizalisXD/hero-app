import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/models/category_id.dart';

/// [D4, XP_SYSTEM_TZ §3] base_xp атрибутов: единственный источник истины —
/// таблица `categories` в БД. Клиент использует эти значения ТОЛЬКО для
/// превью награды; фактический XP считает сервер в complete_task /
/// complete_habit_checkin ([D5]) и клиентское значение игнорирует.
///
/// На ошибке сети возвращает пустую карту — коллсайты падают на
/// `bundle.defaultBaseXp` (превью чуть неточное, награда всё равно
/// серверная).
final categoryBaseXpProvider =
    FutureProvider<Map<CategoryId, int>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final rows = await client.from('categories').select('id, base_xp');
    return {
      for (final r in (rows as List).cast<Map<String, dynamic>>())
        if (CategoryId.fromWire(r['id'] as String?) != null)
          CategoryId.fromWire(r['id'] as String)!:
              (r['base_xp'] as num?)?.toInt() ?? 20,
    };
  } catch (_) {
    return const <CategoryId, int>{};
  }
});
