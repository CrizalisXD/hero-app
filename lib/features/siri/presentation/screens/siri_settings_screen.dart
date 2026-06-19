import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../../core/widgets/hero_card.dart';

class SiriSettingsScreen extends StatelessWidget {
  const SiriSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.siriScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (Platform.isAndroid)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Text(l.siriAndroidComingSoon),
            ),
          if (Platform.isIOS) ...[
            Text(
              l.siriSettingsHowTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              l.siriSettingsHowBody,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _ExampleTile(text: l.siriExampleAddTask),
            _ExampleTile(text: l.siriExampleCompleteTask),
            _ExampleTile(text: l.siriExampleAskCoach),
            _ExampleTile(text: l.siriExampleShowToday),
            _ExampleTile(text: l.siriExampleCreateHabit),
            const SizedBox(height: 16),
            HeroButton(
              label: l.siriSettingsOpenSystem,
              icon: Icons.settings_outlined,
              variant: HeroButtonVariant.secondary,
              onPressed: () async {
                final uri = Uri.parse('app-settings:');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: HeroCard(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
