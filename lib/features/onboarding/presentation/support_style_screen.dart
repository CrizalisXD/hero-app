import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import '../domain/models/support_style.dart';
import 'widgets/onboarding_shell.dart';

class SupportStyleScreen extends ConsumerStatefulWidget {
  const SupportStyleScreen({super.key});

  @override
  ConsumerState<SupportStyleScreen> createState() =>
      _SupportStyleScreenState();
}

class _SupportStyleScreenState extends ConsumerState<SupportStyleScreen> {
  SupportStyle? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(onboardingControllerProvider).supportStyle;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      (value: SupportStyle.direct, label: l.onboardingSupportDirect, desc: l.onboardingSupportDirectDesc),
      (value: SupportStyle.gentle, label: l.onboardingSupportGentle, desc: l.onboardingSupportGentleDesc),
      (value: SupportStyle.strict, label: l.onboardingSupportStrict, desc: l.onboardingSupportStrictDesc),
      (value: SupportStyle.analytical, label: l.onboardingSupportAnalytical, desc: l.onboardingSupportAnalyticalDesc),
    ];

    return OnboardingShell(
      step: 6,
      totalSteps: 9,
      title: l.onboardingSupportTitle,
      subtitle: l.onboardingSupportSubtitle,
      continueEnabled: _selected != null,
      onBack: () => context.go('/onboarding/failure-reason'),
      onContinue: () {
        if (_selected == null) return;
        ref
            .read(onboardingControllerProvider.notifier)
            .setSupportStyle(_selected!);
        context.go('/onboarding/habits');
      },
      content: Column(
        children: options.map((opt) {
          final isSelected = _selected == opt.value;
          return GestureDetector(
            onTap: () => setState(() => _selected = opt.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentDim : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opt.desc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.accent,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
