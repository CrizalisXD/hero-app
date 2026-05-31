import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/locale_notifier.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = ref.watch(localeNotifierProvider).valueOrNull;
    final current = locale?.languageCode ?? 'en';

    Future<void> pick(String code) async {
      final ok =
          await ref.read(localeNotifierProvider.notifier).setLocale(code);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.languageSaveError)),
        );
      }
    }

    Widget tile(String code, String label) {
      final selected = current == code;
      return ListTile(
        title: Text(label),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: () => pick(code),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsSectionLanguage)),
      body: ListView(
        children: [
          tile('ru', l.languageRu),
          tile('en', l.languageEn),
        ],
      ),
    );
  }
}
