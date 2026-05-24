import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

class AvatarConfig {
  const AvatarConfig({required this.primaryColor});
  final String primaryColor;

  factory AvatarConfig.fromJson(Map<String, dynamic> j) =>
      AvatarConfig(primaryColor: j['primary_color'] as String? ?? '#7F77DD');

  static const AvatarConfig fallback = AvatarConfig(primaryColor: '#7F77DD');
}

class AvatarRepository {
  AvatarRepository(this._client);
  final SupabaseClient _client;

  Future<AvatarConfig> getMy() async {
    try {
      final row = await _client
          .from('avatars')
          .select('primary_color')
          .single();
      return AvatarConfig.fromJson(row);
    } catch (_) {
      return AvatarConfig.fallback;
    }
  }
}

final avatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  return AvatarRepository(ref.watch(supabaseClientProvider));
});
