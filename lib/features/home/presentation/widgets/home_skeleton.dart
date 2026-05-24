import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  Widget _box({double w = double.infinity, double h = 16, double r = 8}) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(r),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.bgElevated,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _box(w: 160, h: 22),
        const SizedBox(height: 12),
        _box(h: 10),
        const SizedBox(height: 6),
        _box(w: 100, h: 11),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            4,
            (_) => Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.bgElevated,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                _box(w: 48, h: 10),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _box(h: 90, r: 14),
        const SizedBox(height: 12),
        _box(h: 80, r: 14),
        const SizedBox(height: 12),
        _box(h: 80, r: 14),
      ],
    );
  }
}
