import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local persistence for the guest account flag.
///
/// Supabase SDK already keeps the auth session in its own secure storage,
/// but we mirror two extra fields here so the app can detect guest mode
/// BEFORE the Supabase session is fully restored at cold-start, and so
/// the upgrade UI can verify it's safe to call `auth.updateUser()`.
///
/// Stored keys (per TZ §2.9.2):
///   - guest_mode_active : 'true' if the last successful sign-in was as guest
///   - guest_user_id     : the auth.users.id of that guest session
class GuestAccountLocalStore {
  GuestAccountLocalStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kActive = 'guest_mode_active';
  static const _kUserId = 'guest_user_id';

  /// Mark guest mode active and remember the user_id.
  Future<void> saveGuest(String userId) async {
    await _storage.write(key: _kActive, value: 'true');
    await _storage.write(key: _kUserId, value: userId);
  }

  /// Clear both flags — user is no longer a guest (upgraded or signed out).
  Future<void> clearGuest() async {
    await _storage.delete(key: _kActive);
    await _storage.delete(key: _kUserId);
  }

  /// True if the device thinks it has an active guest session.
  Future<bool> isGuestModeActive() async {
    final v = await _storage.read(key: _kActive);
    return v == 'true';
  }

  /// The remembered guest user_id, or null if none.
  Future<String?> readGuestUserId() async {
    return _storage.read(key: _kUserId);
  }
}

final guestAccountLocalStoreProvider = Provider<GuestAccountLocalStore>(
  (ref) => GuestAccountLocalStore(),
);
