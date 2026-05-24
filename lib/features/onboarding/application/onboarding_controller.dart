import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_onboarding_repository.dart';
import '../domain/models/failure_reason.dart';
import '../domain/models/life_area.dart';
import '../domain/models/starter_habit_key.dart';
import '../domain/models/support_style.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_repository.dart';

class OnboardingController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void setLifeChangeAreas(Set<LifeArea> areas) {
    state = state.copyWith(lifeChangeAreas: areas);
  }

  void setMainObstacle(String obstacle) {
    state = state.copyWith(mainObstacle: obstacle);
  }

  void setEnergyLevel(int level) {
    state = state.copyWith(energyLevel: level);
  }

  void setTimeCommitment(int minutes) {
    state = state.copyWith(timeCommitmentMinutes: minutes);
  }

  void setFailureReasons(Set<FailureReason> reasons) {
    state = state.copyWith(failureReasons: reasons);
  }

  void setSupportStyle(SupportStyle style) {
    state = state.copyWith(supportStyle: style);
  }

  void setStarterHabits(Set<StarterHabitKey> habits) {
    state = state.copyWith(starterHabits: habits);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingDraft>(
  OnboardingController.new,
);

class OnboardingBootstrapController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  Future<bool> submit() async {
    state = const AsyncLoading();
    try {
      final draft = ref.read(onboardingControllerProvider);
      final result = await _repo.bootstrap(draft);

      if (!result.ok || !result.onboardingDone) {
        state = AsyncError(
          Exception('server did not confirm onboarding_done'),
          StackTrace.current,
        );
        return false;
      }

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final onboardingBootstrapProvider =
    AsyncNotifierProvider<OnboardingBootstrapController, void>(
  OnboardingBootstrapController.new,
);
