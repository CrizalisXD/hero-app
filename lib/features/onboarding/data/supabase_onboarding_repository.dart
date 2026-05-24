import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_repository.dart';

/// Thrown when the onboarding Edge Function call fails.
class OnboardingBootstrapException implements Exception {
  const OnboardingBootstrapException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'OnboardingBootstrapException(${statusCode ?? '?'}): $message';
}

class SupabaseOnboardingRepository implements OnboardingRepository {
  SupabaseOnboardingRepository(this._ref);
  final Ref _ref;

  @override
  Future<OnboardingResult> bootstrap(OnboardingDraft draft) async {
    final client = _ref.read(supabaseClientProvider);

    // Invoke the Edge Function — may throw FunctionException on HTTP errors.
    final FunctionResponse res;
    try {
      res = await client.functions.invoke(
        'onboarding-bootstrap',
        body: draft.toJson(),
      );
    } on FunctionException catch (e) {
      throw OnboardingBootstrapException(
        e.details?.toString() ?? 'Function invocation failed',
        statusCode: e.status,
      );
    }

    // Guard: non-200 status means the Edge Function returned an error body.
    if (res.status != 200) {
      throw OnboardingBootstrapException(
        'HTTP ${res.status}',
        statusCode: res.status,
      );
    }

    // Guard: unexpected response format (null, string, HTML, etc.)
    final rawData = res.data;
    if (rawData is! Map<String, dynamic>) {
      throw const OnboardingBootstrapException('Unexpected response format');
    }

    return OnboardingResult(
      ok: (rawData['ok'] as bool?) ?? false,
      onboardingDone: (rawData['onboarding_done'] as bool?) ?? false,
    );
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SupabaseOnboardingRepository(ref);
});
