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
    final row = await _client.from('avatars').select().single();
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
