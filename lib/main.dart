import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/notifications/local_notifications_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  // Global error hooks — without these an uncaught async error is an
  // invisible crash in release builds (no log, no report hook).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[UncaughtAsyncError] $error\n$stack');
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseService.init();
  } catch (e) {
    // Misconfigured env / failed init — show an explanation instead of
    // dying before the first frame with a blank screen.
    runApp(_StartupErrorApp(message: e.toString()));
    return;
  }

  try {
    await LocalNotificationsService.instance.init();
  } catch (e) {
    // Notifications are non-fatal — the app must still boot without them.
    debugPrint('[startup] notifications init failed: $e');
  }

  runApp(const ProviderScope(child: HeroApp()));
}

/// Minimal fallback UI when the app cannot start at all (e.g. missing
/// SUPABASE_URL / SUPABASE_ANON_KEY dart-defines).
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Hero failed to start',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
