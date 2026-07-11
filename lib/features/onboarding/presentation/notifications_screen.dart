import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/notifications/local_notifications_service.dart';
import 'widgets/onboarding_shell.dart';

/// Шаг 11: разрешение на уведомления — с объяснением ценности ДО
/// системного диалога. Привычки без напоминаний не выживают.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _requesting = false;

  Future<void> _enable() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      await LocalNotificationsService.instance.requestPermission();
    } catch (_) {
      // Отказ или сбой — не блокируем онбординг.
    }
    if (!mounted) return;
    setState(() => _requesting = false);
    context.go('/onboarding/first-mission');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return OnboardingShell(
      step: 11,
      totalSteps: 12,
      title: l.onboardingNotifTitle,
      subtitle: l.onboardingNotifSubtitle,
      onBack: () => context.go('/onboarding/habits'),
      continueLabel: l.onboardingNotifEnable,
      isLoading: _requesting,
      onContinue: _enable,
      secondaryLabel: l.onboardingNotifLater,
      onSecondary: () => context.go('/onboarding/first-mission'),
      scrollable: false,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.45),
                    blurRadius: 40,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_active,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _Benefit(text: l.onboardingNotifBenefit1),
          _Benefit(text: l.onboardingNotifBenefit2),
          _Benefit(text: l.onboardingNotifBenefit3),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: AppColors.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
