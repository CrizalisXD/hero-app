import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_onboarding_repository.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_repository.dart';

class OnboardingController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void setDisplayName(String name) {
    state = state.copyWith(displayName: name.trim());
  }

  void setPreferredTime(String time) {
    state = state.copyWith(preferredTime: time);
  }

  void setLifeChangeAreas(List<String> areas) {
    state = state.copyWith(lifeChangeAreas: areas);
  }

  void setMainObstacles(List<String> obstacles) {
    state = state.copyWith(mainObstacles: obstacles);
  }

  void setEnergyLevel(int level) {
    state = state.copyWith(energyLevel: level);
  }

  void setTimeCommitment(int minutes) {
    state = state.copyWith(timeCommitmentMinutes: minutes);
  }

  void setFailureReasons(List<String> reasons) {
    state = state.copyWith(failureReasons: reasons);
  }

  void setSupportStyle(String style) {
    state = state.copyWith(supportStyle: style);
  }

  void setStarterHabits(List<String> habits) {
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
      if (!result.ok) {
        state = AsyncError(
          Exception('bootstrap returned ok=false'),
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
