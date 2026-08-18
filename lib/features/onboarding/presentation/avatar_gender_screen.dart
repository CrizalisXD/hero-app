import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../avatar/application/avatar_draft_notifier.dart';
import '../../avatar/application/avatar_notifier.dart';
import '../../avatar/domain/models/avatar_slot.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 12: выбор базового тела.
///
/// Пол относится к ПЕРСОНАЖУ, а не к анкете пользователя, поэтому пишется в
/// `avatars.avatar_gender` и никак не связан с профилем. Выбор живёт в
/// черновике и уходит на сервер одним сохранением на следующем шаге — здесь
/// в базу ничего не пишется.
class AvatarGenderScreen extends ConsumerWidget {
  const AvatarGenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final saved = ref.watch(avatarNotifierProvider);
    final draft = ref.watch(avatarDraftProvider);

    // Черновик заводится от сохранённой строки, как только она приехала.
    final savedAvatar = saved.valueOrNull;
    if (savedAvatar != null && draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(avatarDraftProvider.notifier).begin(savedAvatar);
      });
    }

    final selected = draft?.gender ?? savedAvatar?.gender;

    return OnboardingShell(
      step: 12,
      totalSteps: 14,
      title: l.onboardingAvatarGenderTitle,
      subtitle: l.onboardingAvatarGenderSubtitle,
      onBack: () => context.go('/onboarding/notifications'),
      continueEnabled: selected != null,
      onContinue: () => context.go('/onboarding/avatar-create'),
      content: SelectableCardGrid(
        options: [
          CardGridOption(
            key: AvatarGender.male.wire,
            label: l.onboardingAvatarGenderMale,
            icon: Icons.man_rounded,
            tint: AppColors.info,
          ),
          CardGridOption(
            key: AvatarGender.female.wire,
            label: l.onboardingAvatarGenderFemale,
            icon: Icons.woman_rounded,
            tint: AppColors.creativity,
          ),
        ],
        selected: {if (selected != null) selected.wire},
        aspectRatio: 0.95,
        onToggle: (key) {
          final gender = AvatarGender.fromWire(key);
          final notifier = ref.read(avatarDraftProvider.notifier);
          if (ref.read(avatarDraftProvider) == null && savedAvatar != null) {
            notifier.begin(savedAvatar);
          }
          // Смена пола сбрасывает несовместимые вещи — на этом шаге
          // сбрасывать ещё нечего, но правило одно для всех точек входа.
          notifier.setGender(gender);
        },
      ),
    );
  }
}
