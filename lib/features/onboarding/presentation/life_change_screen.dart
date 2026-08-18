import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 2: направления. Все 7 атрибутов системы (XP_SYSTEM_TZ §1) в их
/// фирменных цветах; выбор до 3, чтобы персонализация не размывалась.
class LifeChangeScreen extends ConsumerStatefulWidget {
  const LifeChangeScreen({super.key});

  @override
  ConsumerState<LifeChangeScreen> createState() => _LifeChangeScreenState();
}

class _LifeChangeScreenState extends ConsumerState<LifeChangeScreen> {
  final Set<String> _selected = {};
  static const _maxSelect = 3;

  @override
  void initState() {
    super.initState();
    _selected.addAll(ref.read(onboardingControllerProvider).lifeChangeAreas);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      CardGridOption(
        key: 'strength',
        label: l.onboardingAreaStrength,
        icon: Icons.fitness_center,
        tint: AppColors.strength,
      ),
      CardGridOption(
        key: 'endurance',
        label: l.onboardingAreaEndurance,
        icon: Icons.directions_run,
        tint: AppColors.endurance,
      ),
      CardGridOption(
        key: 'mind',
        label: l.onboardingAreaMind,
        icon: Icons.psychology,
        tint: AppColors.mind,
      ),
      CardGridOption(
        key: 'health',
        label: l.onboardingAreaHealth,
        icon: Icons.favorite,
        tint: AppColors.health,
      ),
      CardGridOption(
        key: 'social',
        label: l.onboardingAreaSocial,
        icon: Icons.people,
        tint: AppColors.social,
      ),
      CardGridOption(
        key: 'finance',
        label: l.onboardingAreaFinance,
        icon: Icons.account_balance_wallet,
        tint: AppColors.finance,
      ),
      CardGridOption(
        key: 'creativity',
        label: l.onboardingAreaCreativity,
        icon: Icons.palette,
        tint: AppColors.creativity,
      ),
    ];

    return OnboardingShell(
      step: 2,
      totalSteps: 14,
      title: l.onboardingLifeChangeTitle,
      subtitle: l.onboardingLifeChangeSubtitleV2,
      onBack: () => context.go('/onboarding/name'),
      continueEnabled: _selected.isNotEmpty,
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setLifeChangeAreas(_selected.toList());
        context.go('/onboarding/insight');
      },
      content: SelectableCardGrid(
        options: options,
        selected: _selected,
        multiSelect: true,
        maxSelect: _maxSelect,
        onToggle: (key) => setState(() {
          if (_selected.contains(key)) {
            _selected.remove(key);
          } else if (_selected.length < _maxSelect) {
            _selected.add(key);
          }
        }),
      ),
    );
  }
}
