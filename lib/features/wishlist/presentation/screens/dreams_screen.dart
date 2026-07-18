import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/dreams_notifier.dart';
import '../../domain/dream.dart';
import '../widgets/dream_card.dart';
import '../widgets/dream_actions_sheet.dart';

/// Фирменный розовый орба «Хочу попробовать» с колеса Home.
const _pink = Color(0xFFFF6FB5);

/// «Хочу попробовать» — мечты, а не цели. Список того, что хочется успеть в
/// жизни: не то, что тащишь и декомпозируешь, а то, что просто живёт, пока не
/// надумаешь. Надумал — уходит в цель или челлендж.
class DreamsScreen extends ConsumerStatefulWidget {
  const DreamsScreen({super.key});

  @override
  ConsumerState<DreamsScreen> createState() => _DreamsScreenState();
}

class _DreamsScreenState extends ConsumerState<DreamsScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  List<Dream> _similar = const [];
  bool _adding = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Пока человек печатает — ищем похожие мечты, чтобы не плодить дубли.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final found =
          await ref.read(dreamsNotifierProvider.notifier).search(value);
      if (mounted) setState(() => _similar = found);
    });
  }

  Future<void> _wish(String title) async {
    final text = title.trim();
    if (text.isEmpty || _adding) return;
    setState(() => _adding = true);
    unawaited(HapticFeedback.selectionClick());
    final id = await ref.read(dreamsNotifierProvider.notifier).wish(text);
    if (!mounted) return;
    setState(() {
      _adding = false;
      _similar = const [];
    });
    if (id != null) {
      _ctrl.clear();
      _focus.unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dreamsAddError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final async = ref.watch(dreamsNotifierProvider);
    final onlyMine = async.valueOrNull?.onlyMine ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.wishlistTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l.dreamSearchTitle,
            onPressed: () => context.push('/wishlist/search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _CaptureField(
                controller: _ctrl,
                focusNode: _focus,
                busy: _adding,
                onChanged: _onChanged,
                onSubmit: () => _wish(_ctrl.text),
              ),
            ),
            if (_similar.isNotEmpty)
              _SimilarStrip(
                dreams: _similar,
                onPick: (d) => _wish(d.title),
              ),
            _FilterBar(
              onlyMine: onlyMine,
              onChanged: (v) =>
                  ref.read(dreamsNotifierProvider.notifier).setOnlyMine(v),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    l.dreamsLoadError,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                data: (state) {
                  final cards = state.visible;
                  if (cards.isEmpty) return const _EmptyState();
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(dreamsNotifierProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: cards.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final card = cards[i];
                        return DreamCardTile(
                          card: card,
                          onWant: () => ref
                              .read(dreamsNotifierProvider.notifier)
                              .toggleWant(card.dream.id),
                          onOpen: () =>
                              context.push('/wishlist/${card.dream.id}'),
                          onLongPress: () => showDreamActions(
                            context,
                            ref,
                            dreamId: card.dream.id,
                            title: card.dream.title,
                            onOpen: () =>
                                context.push('/wishlist/${card.dream.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureField extends StatelessWidget {
  const _CaptureField({
    required this.controller,
    required this.focusNode,
    required this.busy,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLength: 120,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmit(),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: l.dreamsCaptureHint,
        counterText: '',
        filled: true,
        fillColor: AppColors.bgCard,
        prefixIcon: const Icon(Icons.add, color: _pink),
        suffixIcon: busy
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Подсказка «уже есть такая мечта» — тап присоединяет к канонической,
/// вместо создания дубля.
class _SimilarStrip extends StatelessWidget {
  const _SimilarStrip({required this.dreams, required this.onPick});

  final List<Dream> dreams;
  final ValueChanged<Dream> onPick;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 2),
              child: Text(
                context.l10n.dreamsSimilarHint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in dreams)
                  ActionChip(
                    label: Text(d.title),
                    onPressed: () => onPick(d),
                    backgroundColor: AppColors.bgCard,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    avatar: Text(
                      _fmtWant(d.wantCount),
                      style: const TextStyle(color: _pink, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtWant(int n) =>
      n < 1000 ? '$n' : '${(n / 1000).toStringAsFixed(1)}k';
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.onlyMine, required this.onChanged});

  final bool onlyMine;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _Segment(
            label: l.dreamsFilterAll,
            active: !onlyMine,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 8),
          _Segment(
            label: l.dreamsFilterMine,
            active: onlyMine,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _pink : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF4B1528) : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: active ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_pink.withValues(alpha: 0.18), Colors.transparent],
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: _pink, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              l.dreamsEmptyTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.dreamsEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
