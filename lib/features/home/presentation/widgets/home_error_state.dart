import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';

class HomeErrorState extends StatelessWidget {
  const HomeErrorState({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 52, color: Color(0xB3FFFFFF)),
            const SizedBox(height: 16),
            Text(
              l.homeError,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: Text(l.homeRetry)),
          ],
        ),
      ),
    );
  }
}
