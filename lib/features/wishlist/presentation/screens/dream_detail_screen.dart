import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/dream_detail_notifier.dart';
import '../dream_export.dart';
import '../widgets/dream_doers_list.dart';
import '../widgets/dream_comments.dart';
import '../widgets/dream_rating_row.dart';

const _pink = Color(0xFFFF6FB5);

/// Детальный экран одной мечты: три метрики крупно, действия (тоже хочу /
/// сделал), экспорт в цель и челлендж, «кто уже сделал» и обсуждение.
class DreamDetailScreen extends ConsumerWidget {
  const DreamDetailScreen({super.key, required this.dreamId});

  final String dreamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(dreamDetailProvider(dreamId));
    final notifier = ref.read(dreamDetailProvider(dreamId).notifier);

    return Scaffold(
      appBar: AppBar(
        actions: [
          async.maybeWhen(
            data: (_) => IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: l.dreamDetailReport,
              onPressed: () async {
                await notifier.report('user_report');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.dreamDetailReported)),
                  );
                }
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            l.dreamsLoadError,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (detail) {
          final d = detail.dream;
          final follow = detail.card.follow;
          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  d.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                _Metrics(
                  want: d.wantCount,
                  difficulty: d.difficultyAvg,
                  worth: d.worthAvg,
                ),
                const SizedBox(height: 20),
                _PrimaryActions(
                  isMine: detail.card.isMine,
                  onWant: notifier.toggleWant,
                  onGoal: () =>
                      DreamExport.toGoal(context, ref, d.title, dreamId: d.id),
                  onChallenge: () => DreamExport.toChallenge(context, d.title),
                ),
                const SizedBox(height: 24),

                // Голосование за сложность видно всем — сложность определяет
                // сообщество, а не только автор.
                DreamRatingRow(
                  question: l.dreamDetailDifficultyQuestion,
                  value: detail.myDifficultyVote,
                  color: AppColors.accent,
                  onRate: notifier.voteDifficulty,
                ),

                // «Сделал» и «стоило того» — только для своих мечт, и worth
                // открывается лишь после отметки «сделал».
                if (detail.card.isMine) ...[
                  const SizedBox(height: 16),
                  _DoneBlock(
                    done: follow?.isDone ?? false,
                    worth: follow?.worthRating,
                    isPublic: follow?.isPublic ?? false,
                    onToggleDone: (v) => notifier.setDone(done: v),
                    onWorth: notifier.setWorth,
                    onPublic: (v) => notifier.setPublic(isPublic: v),
                  ),
                ],

                const SizedBox(height: 28),
                DreamDoersList(doers: detail.doers),
                const SizedBox(height: 28),
                DreamComments(
                  comments: detail.comments,
                  onSubmit: notifier.addComment,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.want, this.difficulty, this.worth});

  final int want;
  final double? difficulty;
  final double? worth;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            value: _fmt(want),
            label: l.dreamsStatWant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            value: difficulty?.toStringAsFixed(1) ?? '—',
            label: l.dreamsStatDifficulty,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          // «Стоило того» подсвечено: его нельзя накрутить, оно заработано.
          child: _MetricTile(
            value: worth?.toStringAsFixed(1) ?? '—',
            label: worth == null ? l.dreamsUncharted : l.dreamsStatWorth,
            color: worth == null ? null : AppColors.success,
          ),
        ),
      ],
    );
  }

  static String _fmt(int n) =>
      n < 1000 ? '$n' : '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({
    required this.isMine,
    required this.onWant,
    required this.onGoal,
    required this.onChallenge,
  });

  final bool isMine;
  final Future<void> Function() onWant;
  final VoidCallback onGoal;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: isMine ? AppColors.bgCard : _pink,
              foregroundColor: isMine ? _pink : const Color(0xFF4B1528),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(isMine ? Icons.favorite : Icons.favorite_border),
            label: Text(isMine ? l.dreamsWantRemove : l.dreamsWant),
            onPressed: () {
              HapticFeedback.selectionClick();
              onWant();
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: _outlined,
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text(l.dreamsToGoal),
                onPressed: onGoal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: _outlined,
                icon: const Icon(Icons.emoji_events_outlined, size: 18),
                label: Text(l.dreamsToChallenge),
                onPressed: onChallenge,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ButtonStyle get _outlined => OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF2A2A36)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      );
}

/// Блок «я это сделал»: отметка, оценка «стоило того» (открывается только
/// после отметки) и публичность следа.
class _DoneBlock extends StatelessWidget {
  const _DoneBlock({
    required this.done,
    required this.worth,
    required this.isPublic,
    required this.onToggleDone,
    required this.onWorth,
    required this.onPublic,
  });

  final bool done;
  final int? worth;
  final bool isPublic;
  final ValueChanged<bool> onToggleDone;
  final ValueChanged<int?> onWorth;
  final ValueChanged<bool> onPublic;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.success,
            title: Text(
              done ? l.dreamDetailUndone : l.dreamDetailDone,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            value: done,
            onChanged: onToggleDone,
          ),
          if (done) ...[
            const Divider(color: Color(0xFF2A2A36)),
            const SizedBox(height: 8),
            DreamRatingRow(
              question: l.dreamDetailWorthQuestion,
              value: worth,
              color: AppColors.success,
              icon: Icons.star,
              onRate: onWorth,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: _pink,
              title: Text(
                l.dreamDetailPublicToggle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              value: isPublic,
              onChanged: onPublic,
            ),
          ],
        ],
      ),
    );
  }
}
