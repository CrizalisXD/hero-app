import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';

class LevelUpOverlay {
  static Future<void> show(BuildContext context, {required int newLevel}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _LevelUpDialog(level: newLevel),
    );
  }
}

class _LevelUpDialog extends StatefulWidget {
  const _LevelUpDialog({required this.level});
  final int level;

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
      child: AlertDialog(
        backgroundColor: AppColors.bgSheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.xpGradient,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.levelUpTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.levelUpSubtitle(widget.level),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xB3FFFFFF),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.levelUpClose),
            ),
          ),
        ],
      ),
    );
  }
}
