import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../avatar/application/avatar_draft_notifier.dart';
import '../../avatar/application/avatar_notifier.dart';
import '../../avatar/domain/models/avatar_slot.dart';
import '../../avatar/presentation/widgets/avatar_slot_editor.dart';
import 'widgets/onboarding_shell.dart';

/// Шаг 13: первичная кастомизация.
///
/// Осознанно короткая: по ТЗ проход должен занимать 30–60 секунд, поэтому
/// здесь только базовые слоты, без запертых предметов и магазина. Полный
/// гардероб живёт в Character Editor на /avatar.
///
/// 3D-превью тут намеренно нет: Unity-движок на этом шаге пришлось бы
/// поднимать посреди онбординга, а стоит он дорого. Герой показывается сразу
/// после — на Home, где движок и так живёт.
class AvatarCreatorScreen extends ConsumerStatefulWidget {
  const AvatarCreatorScreen({super.key});

  @override
  ConsumerState<AvatarCreatorScreen> createState() =>
      _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends ConsumerState<AvatarCreatorScreen> {
  bool _saving = false;

  Future<void> _saveAndContinue() async {
    setState(() => _saving = true);
    final ok = await ref.read(avatarDraftProvider.notifier).save();
    if (!mounted) return;
    setState(() => _saving = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.avatarSaveError)),
      );
      return;
    }
    // Черновик отработал — дальше редактор откроется от сохранённого состояния.
    ref.read(avatarDraftProvider.notifier).discard();
    context.go('/onboarding/first-mission');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final saved = ref.watch(avatarNotifierProvider).valueOrNull;
    final draft = ref.watch(avatarDraftProvider);

    // Черновик мог не завестись, если пользователь попал сюда по прямой
    // ссылке, минуя экран выбора пола.
    if (saved != null && draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ensureAvatarDraft(ref, saved);
      });
    }

    return OnboardingShell(
      step: 13,
      totalSteps: 14,
      title: l.onboardingAvatarCreateTitle,
      subtitle: l.onboardingAvatarCreateSubtitle,
      onBack: () => context.go('/onboarding/avatar-gender'),
      continueEnabled: draft != null && !_saving,
      isLoading: _saving,
      onContinue: _saveAndContinue,
      content: const AvatarSlotEditor(
        // В онбординге — только базовые слоты. Верх и низ прячутся сами,
        // когда надет цельный образ.
        slots: [
          AvatarSlot.hair,
          AvatarSlot.skin,
          AvatarSlot.outfit,
          AvatarSlot.top,
          AvatarSlot.bottom,
          AvatarSlot.shoes,
        ],
      ),
    );
  }
}
