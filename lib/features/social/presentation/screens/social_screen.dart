import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../application/social_notifiers.dart';
import '../widgets/feed_tile.dart';
import '../widgets/friend_request_tile.dart';
import '../widgets/friend_tile.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final friends = ref.watch(friendsNotifierProvider);
    final reqs = ref.watch(friendRequestsNotifierProvider);
    final feed = ref.watch(friendsFeedNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.socialTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined),
            tooltip: l.socialAddFriend,
            onPressed: () => context.push('/social/search'),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l.socialTabFriends),
            Tab(text: l.socialTabRequests),
            Tab(text: l.socialTabFeed),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          friends.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              if (list.isEmpty) return Center(child: Text(l.socialEmptyFriends));
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(friendsNotifierProvider.notifier).refresh(),
                child: ListView(
                  children: list.map((f) => FriendTile(friend: f)).toList(),
                ),
              );
            },
          ),
          reqs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              if (list.isEmpty) return Center(child: Text(l.socialEmptyRequests));
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(friendRequestsNotifierProvider.notifier)
                    .refresh(),
                child: ListView(
                  children:
                      list.map((r) => FriendRequestTile(request: r)).toList(),
                ),
              );
            },
          ),
          feed.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              if (list.isEmpty) return Center(child: Text(l.socialEmptyFeed));
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(friendsFeedNotifierProvider.notifier).refresh(),
                child: ListView(
                  children: list.map((e) => FeedTile(event: e)).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
