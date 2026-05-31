import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
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

  AsyncValue<List<PublicProfile>> _results = const AsyncData([]);

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
          Expanded(
            child: _results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                if (list.isEmpty && _ctrl.text.trim().length >= 2) {
                  return Center(child: Text(l.socialSearchEmpty));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final p = list[i];
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
