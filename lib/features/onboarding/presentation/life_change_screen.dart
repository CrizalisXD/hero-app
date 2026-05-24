import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import '../domain/models/life_area.dart';
import 'widgets/choice_chip_grid.dart';
import 'widgets/onboarding_shell.dart';

class LifeChangeScreen extends ConsumerStatefulWidget {
  const LifeChangeScreen({super.key});

  @override
  ConsumerState<LifeChangeScreen> createState() => _LifeChangeScreenState();
}

class _LifeChangeScreenState extends ConsumerState<LifeChangeScreen> {
  final Set<LifeArea> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(
      ref.read(onboardingControllerProvider).lifeChangeAreas,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      (value: LifeArea.health, label: l.onboardingAreaHealth),
      (value: LifeArea.finance, label: l.onboardingAreaFinance),
      (value: LifeArea.mind, label: l.onboardingAreaMind),
      (value: LifeArea.endurance, label: l.onboardingAreaEndurance),
      (value: LifeArea.social, label: l.onboardingAreaSocial),
      (value: LifeArea.creativity, label: l.onboardingAreaCreativity),
      (value: LifeArea.strength, label: l.onboardingAreaStrength),
      (value: LifeArea.discipline, label: l.onboardingAreaDiscipline),
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
            .setLifeChangeAreas(_selected);
        context.go('/onboarding/main-obstacle');
      },
      content: ChoiceChipGrid<LifeArea>(
        options: options,
        selected: _selected,
        multiSelect: true,
        onToggle: (area) => setState(() {
          if (_selected.contains(area)) {
            _selected.remove(area);
          } else {
            _selected.add(area);
          }
        }),
      ),
    );
  }
}
