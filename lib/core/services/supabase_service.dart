import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import '../errors/app_exception.dart';

class SupabaseService {
  SupabaseService._(this.client);
  final SupabaseClient client;

  static SupabaseService? _instance;
  static SupabaseService get instance {
    final i = _instance;
    if (i == null) {
      throw const AppException('SupabaseService not initialized');
    }
    return i;
  }

  static Future<void> init() async {
    if (!Env.isConfigured) {
      throw const AppException(
        'Supabase env is not configured. '
        'Pass --dart-define=SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _instance = SupabaseService._(Supabase.instance.client);
  }
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.instance.client;
});
