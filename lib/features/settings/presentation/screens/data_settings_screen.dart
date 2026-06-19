import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../auth/application/auth_notifier.dart';
import '../../data/account_lifecycle_repository.dart';

class DataSettingsScreen extends ConsumerStatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  ConsumerState<DataSettingsScreen> createState() =>
      _DataSettingsScreenState();
}

class _DataSettingsScreenState extends ConsumerState<DataSettingsScreen> {
  bool _exporting = false;
  bool _deleting = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    final l = context.l10n;
    try {
      final data = await ref.read(accountLifecycleRepoProvider).exportMyData();
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/hero_export_$ts.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Hero data export',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.dataExportSaved(file.path))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.dataExportError)),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _delete() async {
    if (_deleting) return;
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.accountDeleteConfirmTitle),
        content: Text(l.accountDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.accountDeleteCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.accountDeleteConfirmAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final at = await ref.read(accountLifecycleRepoProvider).requestDeletion();
      if (!mounted) return;
      final dateStr = DateFormat.yMMMd().format(at);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.accountDeleteScheduled(dateStr))),
      );
      // Sign out — even for guests, since user explicitly confirmed deletion.
      await ref.read(authActionsProvider.notifier).signOut(
            acknowledgeGuestDataLoss: true,
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.accountDeleteError)),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.dataExportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeroButton(
            label: _exporting ? l.dataExportPreparing : l.dataExportDownload,
            icon: Icons.download_outlined,
            variant: HeroButtonVariant.secondary,
            isLoading: _exporting,
            onPressed: _exporting ? null : _export,
          ),
          const SizedBox(height: 32),
          Text(
            l.accountDeleteSection,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 12),
          HeroButton(
            label: l.accountDelete,
            icon: Icons.delete_outline,
            variant: HeroButtonVariant.danger,
            isLoading: _deleting,
            onPressed: _deleting ? null : _delete,
          ),
        ],
      ),
    );
  }
}
