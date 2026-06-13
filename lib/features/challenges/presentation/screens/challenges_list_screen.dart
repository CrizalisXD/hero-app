import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../application/challenges_notifier.dart';
import '../../domain/models/challenge.dart';
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
  // null = "All" chip, otherwise filter to a specific kind.
  ChallengeKind? _filter;

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/challenges/new'),
        icon: const Icon(Icons.add),
        label: Text(l.challengesCreateButton),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _AllTab(
            state: all,
            filter: _filter,
            onFilterChange: (f) {
              setState(() => _filter = f);
            },
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

class _AllTab extends ConsumerWidget {
  const _AllTab({
    required this.state,
    required this.filter,
    required this.onFilterChange,
  });
  final AsyncValue<List<Challenge>> state;
  final ChallengeKind? filter;
  final ValueChanged<ChallengeKind?> onFilterChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (raw) {
        // Apply chip filter.
        final list = filter == null
            ? raw
            : raw.where((c) => c.kind == filter).toList();
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(systemChallengesNotifierProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 96),
            children: [
              _KindFilter(active: filter, onChange: onFilterChange, l: l),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child:
                      Center(child: Text(l.challengesEmpty)),
                )
              else
                ...list.map(
                  (c) => ChallengeCard.system(
                    c,
                    onTap: () =>
                        GoRouter.of(context).push('/challenges/${c.id}'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Horizontal scrollable chip row to filter the "All" tab by kind.
class _KindFilter extends StatelessWidget {
  const _KindFilter({
    required this.active,
    required this.onChange,
    required this.l,
  });
  final ChallengeKind? active;
  final ValueChanged<ChallengeKind?> onChange;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final chips = <_ChipSpec>[
      _ChipSpec(label: l.challengesFilterAll, value: null),
      _ChipSpec(label: l.challengesFilterWeekly, value: ChallengeKind.weekly),
      _ChipSpec(
        label: l.challengesFilterSeasonal,
        value: ChallengeKind.seasonal,
      ),
      _ChipSpec(label: l.challengesFilterSystem, value: ChallengeKind.system),
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final c in chips) ...[
            ChoiceChip(
              label: Text(c.label),
              selected: active == c.value,
              onSelected: (_) => onChange(c.value),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ChipSpec {
  const _ChipSpec({required this.label, required this.value});
  final String label;
  final ChallengeKind? value;
}
