import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/avatar_repository.dart';
import '../domain/models/avatar.dart';

class SupabaseAvatarRepository implements AvatarRepository {
  SupabaseAvatarRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<Avatar> getMine() async {
    // maybeSingle: a not-yet-provisioned avatar row must not surface as a
    // cryptic PostgrestException. Run the (idempotent) bootstrap once and
    // retry before giving up.
    var row = await _client.from('avatars').select().maybeSingle();
    if (row == null) {
      try {
        await _client.rpc<dynamic>('ensure_user_bootstrap');
      } catch (_) {}
      row = await _client.from('avatars').select().maybeSingle();
    }
    if (row == null) {
      throw StateError('avatar_not_provisioned');
    }
    return Avatar.fromJson(row);
  }

  @override
  Future<Avatar> updatePrimaryColor(String hex) async {
    final row = await _client
        .from('avatars')
        .update({'primary_color': hex})
        .eq('user_id', _client.auth.currentUser!.id)
        .select()
        .single();
    return Avatar.fromJson(row);
  }
}

/// Provider для AvatarScreen — полная модель.
/// Не трогает существующий avatarRepositoryProvider из home/data/avatar_repository.dart.
final avatarFullRepositoryProvider = Provider<AvatarRepository>((ref) {
  return SupabaseAvatarRepository(ref.watch(supabaseClientProvider));
});
