import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/wishlist_notifier.dart';
import '../../domain/wishlist_item.dart';

/// Фирменный розовый орба «Хочу попробовать» с колеса Home.
const _wishPink = Color(0xFFFF6FB5);

/// «Хочу попробовать» — бэклог идей без лимита: мгновенный захват сверху,
/// свайпы: превратить в задачу / отметить попробованным / удалить.
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _adding = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _adding) return;
    setState(() => _adding = true);
    unawaited(HapticFeedback.selectionClick());
    final ok = await ref.read(wishlistNotifierProvider.notifier).add(text);
    if (!mounted) return;
    setState(() => _adding = false);
    if (ok) {
      _ctrl.clear();
      _focus.requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.wishlistAddError)),
      );
    }
  }

  Future<void> _convert(WishlistItem item) async {
    final ok = await ref
        .read(wishlistNotifierProvider.notifier)
        .convertToTask(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? context.l10n.wishlistConverted(item.title)
              : context.l10n.wishlistConvertError,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(wishlistNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.wishlistTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _CaptureField(
                controller: _ctrl,
                focusNode: _focus,
                busy: _adding,
                onSubmit: _add,
              ),
            ),
            Expanded(
              child: state.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    l.wishlistLoadError,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const _EmptyState()
                    : _WishList(
                        items: items,
                        onToggleTried: (id) => ref
                            .read(wishlistNotifierProvider.notifier)
                            .toggleTried(id),
                        onDelete: (id) => ref
                            .read(wishlistNotifierProvider.notifier)
                            .delete(id),
                        onConvert: _convert,
                      ),
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
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLength: 120,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: l.wishlistCaptureHint,
              counterText: '',
              filled: true,
              fillColor: AppColors.bgCard,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _wishPink, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: busy ? null : onSubmit,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _wishPink,
              boxShadow: [
                BoxShadow(
                  color: _wishPink.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _WishList extends StatelessWidget {
  const _WishList({
    required this.items,
    required this.onToggleTried,
    required this.onDelete,
    required this.onConvert,
  });

  final List<WishlistItem> items;
  final ValueChanged<String> onToggleTried;
  final ValueChanged<String> onDelete;
  final ValueChanged<WishlistItem> onConvert;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final active = items.where((e) => !e.isTried).toList();
    final tried = items.where((e) => e.isTried).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final item in active)
          _WishTile(
            item: item,
            onToggleTried: () => onToggleTried(item.id),
            onDelete: () => onDelete(item.id),
            onConvert: () => onConvert(item),
          ),
        if (tried.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
            child: Text(
              l.wishlistTriedSection,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
          ),
          for (final item in tried)
            _WishTile(
              item: item,
              onToggleTried: () => onToggleTried(item.id),
              onDelete: () => onDelete(item.id),
              onConvert: () => onConvert(item),
            ),
        ],
      ],
    );
  }
}

class _WishTile extends StatelessWidget {
  const _WishTile({
    required this.item,
    required this.onToggleTried,
    required this.onDelete,
    required this.onConvert,
  });

  final WishlistItem item;
  final VoidCallback onToggleTried;
  final VoidCallback onDelete;
  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tried = item.isTried;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: item.isConverted ? 0.5 : 0.72,
          children: [
            if (!item.isConverted)
              SlidableAction(
                onPressed: (_) => onConvert(),
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                icon: Icons.task_alt,
                label: l.wishlistActionToTask,
                borderRadius: BorderRadius.circular(14),
              ),
            SlidableAction(
              onPressed: (_) => onToggleTried(),
              backgroundColor: _wishPink,
              foregroundColor: Colors.white,
              icon: tried ? Icons.replay : Icons.check,
              label: tried ? l.wishlistActionUntried : l.wishlistActionTried,
              borderRadius: BorderRadius.circular(14),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              borderRadius: BorderRadius.circular(14),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withValues(alpha: tried ? 0.5 : 1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tried
                      ? AppColors.bgElevated
                      : _wishPink.withValues(alpha: 0.18),
                ),
                child: Icon(
                  tried ? Icons.check : Icons.lightbulb_outline,
                  size: 20,
                  color: tried ? AppColors.textMuted : _wishPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: tried
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration:
                            tried ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textMuted,
                      ),
                    ),
                    if (item.isConverted)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l.wishlistInTasks,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _wishPink.withValues(alpha: 0.14),
                boxShadow: [
                  BoxShadow(
                    color: _wishPink.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                size: 44,
                color: _wishPink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.wishlistEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.wishlistEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
