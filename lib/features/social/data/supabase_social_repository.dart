import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../rewards/domain/models/unlocked_achievement.dart';
import '../domain/models/feed_event.dart';
import '../domain/models/friend.dart';
import '../domain/models/friend_request.dart';
import '../domain/models/public_profile.dart';

/// Wraps Postgres exceptions thrown by the social RPCs so the UI gets a
/// stable [code] field instead of provider-specific messages.
/// Known codes: rate_limited, already_pending, already_friends, blocked,
/// not_found, cannot_friend_self, cannot_block_self, cannot_report_self,
/// invalid_request, not_authenticated.
class SocialFriendException implements Exception {
  const SocialFriendException(this.code);
  final String code;

  @override
  String toString() => 'SocialFriendException($code)';
}

class SupabaseSocialRepository {
  SupabaseSocialRepository(this._client);
  final SupabaseClient _client;

  /// Stable codes the social RPCs raise with (the code IS the message).
  static const _knownCodes = {
    'rate_limited',
    'already_pending',
    'already_friends',
    'blocked',
    'not_found',
    'cannot_friend_self',
    'cannot_block_self',
    'cannot_report_self',
    'invalid_request',
    'not_authenticated',
  };

  /// Extracts a stable error code from a Postgres exception so callers can
  /// switch on it. Anything unrecognised maps to 'unknown' — raw
  /// provider-specific text must never become the API surface (callers
  /// matching on codes like 'blocked' would silently never match).
  String _stableCode(PostgrestException e) {
    final m = e.message.trim();
    if (_knownCodes.contains(m)) return m;
    for (final c in _knownCodes) {
      if (m.contains(c)) return c;
    }
    return 'unknown';
  }

  // ── Search & profile ──────────────────────────────────────────
  Future<List<PublicProfile>> search(String query) async {
    final rows = await _client
        .rpc<dynamic>('search_users', params: {'p_query': query});
    if (rows is! List) return const [];
    return rows.map((e) {
      final m = (e as Map).cast<String, dynamic>();
      // search RPC doesn't include achievements_count — default to 0.
      return PublicProfile.fromJson({...m, 'achievements_count': 0});
    }).toList();
  }

  Future<PublicProfile> getProfile(String userId) async {
    try {
      final res = await _client.rpc<dynamic>(
        'get_public_profile',
        params: {'p_user_id': userId},
      );
      if (res is! Map) {
        throw const SocialFriendException('invalid_response');
      }
      return PublicProfile.fromJson(res.cast<String, dynamic>());
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  // ── Friends list ──────────────────────────────────────────────
  Future<List<Friend>> listFriends() async {
    final rows = await _client.rpc<dynamic>('list_my_friends');
    if (rows is! List) return const [];
    return rows
        .map((e) => Friend.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<FriendRequest>> listPendingRequests() async {
    final rows = await _client.rpc<dynamic>('list_pending_requests');
    if (rows is! List) return const [];
    return rows
        .map((e) => FriendRequest.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // ── Mutations ─────────────────────────────────────────────────
  Future<void> sendRequest(String receiverId) async {
    try {
      await _client.rpc<dynamic>(
        'send_friend_request',
        params: {'p_receiver_id': receiverId},
      );
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  /// Returns achievements that may have unlocked for the accepter
  /// (social_first_friend in particular).
  Future<List<UnlockedAchievement>> acceptRequest(String requestId) async {
    try {
      final res = await _client.rpc<dynamic>(
        'accept_friend_request',
        params: {'p_request_id': requestId},
      );
      final m = res is Map ? res.cast<String, dynamic>() : const <String, dynamic>{};
      return UnlockedAchievement.listFromJson(m['unlocked_achievements']);
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  Future<void> declineRequest(String requestId) async {
    try {
      await _client.rpc<dynamic>(
        'decline_friend_request',
        params: {'p_request_id': requestId},
      );
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _client.rpc<dynamic>(
        'cancel_friend_request',
        params: {'p_request_id': requestId},
      );
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _client.rpc<dynamic>(
        'remove_friendship',
        params: {'p_friend_id': friendId},
      );
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _client.rpc<dynamic>(
        'block_user',
        params: {'p_user_id': userId},
      );
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  Future<void> reportUser(
    String userId,
    String reason,
    String? details,
  ) async {
    try {
      await _client.rpc<dynamic>(
        'report_user',
        params: {
          'p_user_id': userId,
          'p_reason': reason,
          'p_details': details,
        },
      );
    } on PostgrestException catch (e) {
      throw SocialFriendException(_stableCode(e));
    }
  }

  // ── Feed ──────────────────────────────────────────────────────
  Future<List<FeedEvent>> listFeed({int limit = 50}) async {
    final rows = await _client.rpc<dynamic>(
      'list_friends_feed',
      params: {'p_limit': limit},
    );
    if (rows is! List) return const [];
    return rows
        .map((e) => FeedEvent.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}

final socialRepositoryProvider = Provider<SupabaseSocialRepository>(
  (ref) => SupabaseSocialRepository(ref.watch(supabaseClientProvider)),
);
