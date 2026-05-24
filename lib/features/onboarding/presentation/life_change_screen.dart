import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/choice_chip_grid.dart';
import 'widgets/onboarding_shell.dart';

class LifeChangeScreen extends ConsumerStatefulWidget {
  const LifeChangeScreen({super.key});

  @override
  ConsumerState<LifeChangeScreen> createState() => _LifeChangeScreenState();
}

class _LifeChangeScreenState extends ConsumerState<LifeChangeScreen> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    final existing =
        ref.read(onboardingControllerProvider).lifeChangeAreas;
    _selected.addAll(existing);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      (key: 'health', label: l.onboardingAreaHealth),
      (key: 'finance', label: l.onboardingAreaFinance),
      (key: 'mind', label: l.onboardingAreaMind),
      (key: 'endurance', label: l.onboardingAreaEndurance),
      (key: 'social', label: l.onboardingAreaSocial),
      (key: 'creativity', label: l.onboardingAreaCreativity),
      (key: 'strength', label: l.onboardingAreaStrength),
      (key: 'discipline', label: l.onboardingAreaDiscipline),
    ];

    return OnboardingShell(
      step: 1,
      totalSteps: 9,
      title: l.onboardingLifeChangeTitle,
      subtitle: l.onboardingLifeChangeSubtitle,
      continueEnabled: _selected.isNotEmpty,
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setLifeChangeAreas(_selected.toList());
        context.go('/onboarding/main-obstacle');
      },
      content: ChoiceChipGrid(
        options: options,
        selected: _selected,
        multiSelect: true,
        onToggle: (key) => setState(() {
          if (_selected.contains(key)) {
            _selected.remove(key);
          } else {
            _selected.add(key);
          }
        }),
      ),
    );
  }
}
