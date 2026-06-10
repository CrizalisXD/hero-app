import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../application/challenges_notifier.dart';
import '../widgets/challenge_card.dart';

class ChallengesListScreen extends ConsumerStatefulWidget {
  const ChallengesListScreen({super.key});

  @override
  ConsumerState<ChallengesListScreen> createState() =>
      _ChallengesListScreenState();
}

class _ChallengesListScreenState extends ConsumerState<ChallengesListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final all = ref.watch(systemChallengesNotifierProvider);
    final mine = ref.watch(myChallengesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.challengesTitle),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l.challengesAllTab),
            Tab(text: l.challengesMineTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          all.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(l.challengesEmpty))
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(systemChallengesNotifierProvider.notifier)
                        .refresh(),
                    child: ListView(
                      children: list
                          .map(
                            (c) => ChallengeCard.system(
                              c,
                              onTap: () =>
                                  context.push('/challenges/${c.id}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
          mine.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(l.challengesEmptyMine))
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(myChallengesNotifierProvider.notifier)
                        .refresh(),
                    child: ListView(
                      children: list
                          .map(
                            (p) => ChallengeCard.participant(
                              p,
                              onTap: () => context
                                  .push('/challenges/${p.challengeId}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
