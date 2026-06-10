import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n.dart';

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
                color: const Color(0x33F39C12),
                borderRadius: BorderRadius.circular(8),
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
              style: const TextStyle(color: Color(0xB3FFFFFF)),
            ),
            const SizedBox(height: 16),
            _ExampleTile(text: l.siriExampleAddTask),
            _ExampleTile(text: l.siriExampleCompleteTask),
            _ExampleTile(text: l.siriExampleAskCoach),
            _ExampleTile(text: l.siriExampleShowToday),
            _ExampleTile(text: l.siriExampleCreateHabit),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings_outlined),
              label: Text(l.siriSettingsOpenSystem),
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
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF16161E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
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
