import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/dreams_notifier.dart';
import '../../domain/dream.dart';
import '../widgets/dream_card.dart';

/// Поиск по популярным мечтам — чтобы не листать витрину, а найти нужную.
/// Опирается на RPC search_dreams (триграммы): «парашют» находит «Прыгнуть
/// с парашютом».
class DreamSearchScreen extends ConsumerStatefulWidget {
  const DreamSearchScreen({super.key});

  @override
  ConsumerState<DreamSearchScreen> createState() => _DreamSearchScreenState();
}

class _DreamSearchScreenState extends ConsumerState<DreamSearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Dream> _results = const [];
  bool _searched = false;
  bool _busy = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = const [];
        _searched = false;
      });
      return;
    }
    setState(() => _busy = true);
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      final found =
          await ref.read(dreamsNotifierProvider.notifier).search(value);
      if (!mounted) return;
      setState(() {
        _results = found;
        _searched = true;
        _busy = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: l.dreamSearchHint,
            border: InputBorder.none,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: !_searched
          ? const SizedBox.shrink()
          : _results.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l.dreamSearchEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final d = _results[i];
                    return DreamCardTile(
                      card: DreamCard(dream: d),
                      onWant: () => ref
                          .read(dreamsNotifierProvider.notifier)
                          .toggleWant(d.id),
                      onOpen: () => context.push('/wishlist/${d.id}'),
                    );
                  },
                ),
    );
  }
}
