import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../dream_export.dart';

/// Меню действий над готовой мечтой из списка: открыть, отправить в цель
/// (с разбивкой на этапы) или в челлендж. Вызывается по долгому нажатию —
/// быстрый доступ, не заходя на детальный экран.
Future<void> showDreamActions(
  BuildContext context,
  WidgetRef ref, {
  required String dreamId,
  required String title,
  required VoidCallback onOpen,
}) {
  final l = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            _ActionRow(
              icon: Icons.open_in_full,
              label: l.dreamActionOpen,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onOpen();
              },
            ),
            _ActionRow(
              icon: Icons.flag_outlined,
              label: l.dreamsToGoal,
              onTap: () {
                Navigator.of(sheetContext).pop();
                DreamExport.toGoal(context, ref, title, dreamId: dreamId);
              },
            ),
            _ActionRow(
              icon: Icons.emoji_events_outlined,
              label: l.dreamsToChallenge,
              onTap: () {
                Navigator.of(sheetContext).pop();
                DreamExport.toChallenge(context, title);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}
