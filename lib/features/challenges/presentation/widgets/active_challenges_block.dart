import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/challenges_notifier.dart';
import '../../domain/models/challenge_metric_type.dart';
import 'challenge_card.dart';

/// Lightweight HomeScreen block: up to 2 actively-joined challenges.
/// Hides itself if there's nothing to show — avoids an empty card.
class ActiveChallengesBlock extends ConsumerWidget {
  const ActiveChallengesBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine =
        ref.watch(myChallengesNotifierProvider).valueOrNull ?? const [];
    final active = mine
        .where((p) => p.status == ChallengeStatus.joined)
        .take(2)
        .toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Column(
      children: active
          .map(
            (p) => ChallengeCard.participant(
              p,
              onTap: () =>
                  GoRouter.of(context).push('/challenges/${p.challengeId}'),
            ),
          )
          .toList(),
    );
  }
}
