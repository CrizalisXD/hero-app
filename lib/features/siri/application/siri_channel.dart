import 'package:flutter/services.dart';

/// Thin wrapper around the platform method channel registered by
/// AppDelegate.swift. iOS is the only platform that supplies a real
/// handler; on Android the invocation silently returns null.
class SiriChannel {
  SiriChannel._();
  static const _channel = MethodChannel('hero.siri');

  /// Pulls the payload an App Intent stashed in UserDefaults (one-shot).
  /// Returns null when there is nothing pending or the platform call
  /// fails (e.g. on Android).
  static Future<Map<String, dynamic>?> consumePending() async {
    try {
      final res = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('consume_pending_intent');
      if (res == null) return null;
      return res.cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }
}
