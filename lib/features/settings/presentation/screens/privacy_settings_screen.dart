import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../data/user_consents_repository.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState
    extends ConsumerState<PrivacySettingsScreen> {
  Map<String, bool>? _consents;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final map = await ref.read(userConsentsRepoProvider).getMine();
      if (mounted) setState(() => _consents = map);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _set(String key, bool v) async {
    final previous = _consents?[key] ?? false;
    setState(() => _consents = {...?_consents, key: v});
    try {
      await ref.read(userConsentsRepoProvider).setConsent(key, v);
    } catch (_) {
      // Rollback.
      if (mounted) {
        setState(() => _consents = {...?_consents, key: previous});
      }
    }
  }

  Widget _switch(String key, String label) {
    final v = _consents?[key] ?? false;
    return SwitchListTile.adaptive(
      title: Text(label),
      value: v,
      onChanged: (nv) => _set(key, nv),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (_consents == null && _error == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.consentsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_consents == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.consentsTitle)),
        body: Center(child: Text(_error ?? '—')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.consentsTitle)),
      body: ListView(
        children: [
          _section(l.consentsSectionAi, [
            _switch(ConsentKeys.aiOnboarding, l.consentAiOnboarding),
            _switch(ConsentKeys.aiTasks, l.consentAiTasks),
            _switch(ConsentKeys.aiHabits, l.consentAiHabits),
            _switch(ConsentKeys.aiGoals, l.consentAiGoals),
            _switch(ConsentKeys.aiHealth, l.consentAiHealth),
            _switch(ConsentKeys.aiCalendar, l.consentAiCalendar),
            _switch(ConsentKeys.aiNotes, l.consentAiNotes),
          ]),
          _section(l.consentsSectionSocial, [
            _switch(ConsentKeys.socialSearchable, l.consentSocialSearchable),
            _switch(
              ConsentKeys.socialShowAchievements,
              l.consentSocialShowAchievements,
            ),
            _switch(
              ConsentKeys.socialShowChallenges,
              l.consentSocialShowChallenges,
            ),
          ]),
          _section(l.consentsSectionIntegrations, [
            _switch(
              ConsentKeys.integrationCalendarRead,
              l.consentIntegrationCalendarRead,
            ),
            _switch(
              ConsentKeys.integrationCalendarWrite,
              l.consentIntegrationCalendarWrite,
            ),
            _switch(
              ConsentKeys.integrationHealthRead,
              l.consentIntegrationHealthRead,
            ),
            _switch(
              ConsentKeys.integrationTasksSync,
              l.consentIntegrationTasksSync,
            ),
          ]),
        ],
      ),
    );
  }
}
