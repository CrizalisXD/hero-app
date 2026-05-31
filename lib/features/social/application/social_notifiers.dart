import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_social_repository.dart';
import '../domain/models/feed_event.dart';
import '../domain/models/friend.dart';
import '../domain/models/friend_request.dart';

part 'social_notifiers.g.dart';

@Riverpod(keepAlive: true)
class FriendsNotifier extends _$FriendsNotifier {
  @override
  Future<List<Friend>> build() =>
      ref.read(socialRepositoryProvider).listFriends();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(socialRepositoryProvider).listFriends(),
    );
  }
}

@Riverpod(keepAlive: true)
class FriendRequestsNotifier extends _$FriendRequestsNotifier {
  @override
  Future<List<FriendRequest>> build() =>
      ref.read(socialRepositoryProvider).listPendingRequests();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(socialRepositoryProvider).listPendingRequests(),
    );
  }
}

@Riverpod(keepAlive: true)
class FriendsFeedNotifier extends _$FriendsFeedNotifier {
  @override
  Future<List<FeedEvent>> build() =>
      ref.read(socialRepositoryProvider).listFeed();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(socialRepositoryProvider).listFeed(),
    );
  }
}
