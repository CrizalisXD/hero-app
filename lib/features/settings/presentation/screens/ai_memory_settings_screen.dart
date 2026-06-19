import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../data/account_lifecycle_repository.dart';

class AiMemorySettingsScreen extends ConsumerWidget {
  const AiMemorySettingsScreen({super.key});

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.aiMemoryClearConfirm),
        content: Text(l.aiMemoryClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.accountSignOutCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.aiMemoryClear),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(accountLifecycleRepoProvider).clearAiMemory();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.aiMemoryClearSuccess)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.aiMemoryClearError)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.aiMemoryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.aiMemoryEnabledLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l.aiMemoryEnabledBody,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          HeroButton(
            label: l.aiMemoryClear,
            icon: Icons.delete_outline,
            variant: HeroButtonVariant.danger,
            onPressed: () => _clear(context, ref),
          ),
        ],
      ),
    );
  }
}
