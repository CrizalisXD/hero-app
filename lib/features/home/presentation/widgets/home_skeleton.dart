import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// Home loading state.
///
/// Replaces the old grey box skeleton with a calm branded loader that matches
/// the immersive hero home: a dark stage with a soft accent glow and a spinner.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF15131F), AppColors.bg],
        ),
      ),
      child: Center(child: _GlowLoader()),
    );
  }
}

class _GlowLoader extends StatelessWidget {
  const _GlowLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          height: 34,
          width: 34,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
