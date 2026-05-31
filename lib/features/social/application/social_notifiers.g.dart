// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written — analyzer_plugin 0.12.0 ↔ analyzer 7.x conflict blocks
// `dart run build_runner build`. Same approach as other *.g.dart in tree.

part of 'social_notifiers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendsNotifierHash() => r'phase13-friends-notifier-v1';

/// See also [FriendsNotifier].
@ProviderFor(FriendsNotifier)
final friendsNotifierProvider =
    AsyncNotifierProvider<FriendsNotifier, List<Friend>>.internal(
  FriendsNotifier.new,
  name: r'friendsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendsNotifier = AsyncNotifier<List<Friend>>;

String _$friendRequestsNotifierHash() =>
    r'phase13-friend-requests-notifier-v1';

/// See also [FriendRequestsNotifier].
@ProviderFor(FriendRequestsNotifier)
final friendRequestsNotifierProvider = AsyncNotifierProvider<
    FriendRequestsNotifier, List<FriendRequest>>.internal(
  FriendRequestsNotifier.new,
  name: r'friendRequestsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendRequestsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendRequestsNotifier = AsyncNotifier<List<FriendRequest>>;

String _$friendsFeedNotifierHash() => r'phase13-friends-feed-notifier-v1';

/// See also [FriendsFeedNotifier].
@ProviderFor(FriendsFeedNotifier)
final friendsFeedNotifierProvider =
    AsyncNotifierProvider<FriendsFeedNotifier, List<FeedEvent>>.internal(
  FriendsFeedNotifier.new,
  name: r'friendsFeedNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsFeedNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendsFeedNotifier = AsyncNotifier<List<FeedEvent>>;
// ignore_for_file: type=lint
