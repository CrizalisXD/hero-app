import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_error_view.dart';
import '../../data/supabase_social_repository.dart';
import '../../domain/models/public_profile.dart';

class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() =>
      _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  /// Which field to match. The RPC returns matches on both username and
  /// display_name; this toggle narrows the shown results to the chosen one.
  bool _byNick = true;

  AsyncValue<List<PublicProfile>> _results = const AsyncData([]);

  /// Client-side field filter for the [_byNick] toggle. Mirrors the RPC's
  /// per-field rule: username = prefix, display_name = substring.
  List<PublicProfile> _filter(List<PublicProfile> list) {
    final q = _ctrl.text.replaceFirst(RegExp(r'^@+'), '').trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) {
      return _byNick
          ? p.username.toLowerCase().startsWith(q)
          : p.displayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      setState(() => _results = const AsyncData([]));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _run(q));
  }

  Future<void> _run(String q) async {
    setState(() => _results = const AsyncLoading());
    try {
      final list = await ref.read(socialRepositoryProvider).search(q);
      if (!mounted) return;
      setState(() => _results = AsyncData(list));
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _results = AsyncError(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.socialSearch)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l.socialSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(l.socialSearchByNick),
                  icon: const Icon(Icons.alternate_email, size: 16),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(l.socialSearchByName),
                  icon: const Icon(Icons.person_outline, size: 16),
                ),
              ],
              selected: {_byNick},
              onSelectionChanged: (s) => setState(() => _byNick = s.first),
            ),
          ),
          Expanded(
            child: _results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const HeroErrorView(),
              data: (list) {
                final filtered = _filter(list);
                if (filtered.isEmpty && _ctrl.text.trim().length >= 2) {
                  return Center(child: Text(l.socialSearchEmpty));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (c, i) {
                    final p = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.bgElevated,
                        backgroundImage: p.avatarPreviewUrl != null
                            ? NetworkImage(p.avatarPreviewUrl!)
                            : null,
                        child: p.avatarPreviewUrl == null
                            ? const Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                              )
                            : null,
                      ),
                      title: Text('@${p.username}'),
                      subtitle: Text(p.displayName),
                      onTap: () => context.push('/social/profile/${p.userId}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
