import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../application/social_notifiers.dart';
import '../../data/supabase_social_repository.dart';
import '../../domain/models/public_profile.dart';
import '../widgets/report_user_sheet.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  AsyncValue<PublicProfile> _profile = const AsyncLoading();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _profile = const AsyncLoading());
    try {
      final p = await ref.read(socialRepositoryProvider).getProfile(widget.userId);
      if (!mounted) return;
      setState(() => _profile = AsyncData(p));
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _profile = AsyncError(e, st));
    }
  }

  Future<void> _sendRequest() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = context.l10n;
    try {
      await ref.read(socialRepositoryProvider).sendRequest(widget.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.friendRequestSent)),
      );
    } on SocialFriendException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'rate_limited' => l.friendRequestRateLimited,
        'already_pending' || 'already_friends' => l.friendRequestExists,
        _ => l.friendActionError,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _block(PublicProfile p) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.blockConfirmTitle('@${p.username}')),
        content: Text(l.blockConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.blockCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.blockConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(socialRepositoryProvider).blockUser(widget.userId);
      if (!mounted) return;
      ref.invalidate(friendsNotifierProvider);
      ref.invalidate(friendRequestsNotifierProvider);
      Navigator.of(context).pop();
    } on SocialFriendException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.friendActionError)),
      );
    }
  }

  Future<void> _report() async {
    await ReportUserSheet.show(context, ref, userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.publicProfileTitle),
        actions: [
          _profile.maybeWhen(
            data: (p) => PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'block') _block(p);
                if (v == 'report') _report();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'block', child: Text(l.friendActionBlock)),
                PopupMenuItem(value: 'report', child: Text(l.friendActionReport)),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: _profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l.friendActionError)),
        data: (p) => _body(context, p),
      ),
    );
  }

  Widget _body(BuildContext context, PublicProfile p) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        Center(
          child: CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.bgElevated,
            backgroundImage: p.avatarPreviewUrl != null
                ? NetworkImage(p.avatarPreviewUrl!)
                : null,
            child: p.avatarPreviewUrl == null
                ? const Icon(
                    Icons.person,
                    size: 56,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '@${p.username}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            p.displayName,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        if (p.publicTitle != null) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              p.publicTitle!,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _statRow(Icons.star_outline, l.publicProfileLevel(p.publicLevel)),
        if (p.streak != null)
          _statRow(
            Icons.local_fire_department_outlined,
            l.publicProfileStreak(p.streak!),
          ),
        _statRow(
          Icons.emoji_events_outlined,
          l.publicProfileAchievementsCount(p.achievementsCount),
        ),
        const SizedBox(height: 32),
        HeroButton(
          label: l.socialAddFriend,
          icon: Icons.person_add_alt,
          isLoading: _busy,
          onPressed: _busy ? null : _sendRequest,
        ),
      ],
    );
  }

  Widget _statRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
