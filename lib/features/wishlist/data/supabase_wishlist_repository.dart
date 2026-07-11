import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/wishlist_item.dart';

class SupabaseWishlistRepository {
  SupabaseWishlistRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('not_authenticated');
    return id;
  }

  Future<List<WishlistItem>> list() async {
    final rows = await _client
        .from('wishlist_items')
        .select()
        .eq('user_id', _uid)
        .eq('is_deleted', false)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => WishlistItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<WishlistItem> add(String title) async {
    final row = await _client
        .from('wishlist_items')
        .insert({'user_id': _uid, 'title': title.trim()})
        .select()
        .single();
    return WishlistItem.fromJson(row);
  }

  Future<void> markTried(String id, {required bool tried}) async {
    await _client.from('wishlist_items').update({
      'tried_at': tried ? DateTime.now().toUtc().toIso8601String() : null,
    }).eq('id', id);
  }

  Future<void> linkTask(String id, String taskId) async {
    await _client
        .from('wishlist_items')
        .update({'converted_task_id': taskId}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client
        .from('wishlist_items')
        .update({'is_deleted': true}).eq('id', id);
  }
}

final wishlistRepositoryProvider = Provider<SupabaseWishlistRepository>(
  (ref) => SupabaseWishlistRepository(ref.watch(supabaseClientProvider)),
);
