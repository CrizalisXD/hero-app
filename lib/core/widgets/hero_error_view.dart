import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'hero_button.dart';

/// Friendly, reusable error state for AsyncValue.error branches.
///
/// Never shows the raw exception to the user — technical details belong in
/// debug logs only. Pass [onRetry] to surface a retry button (typically
/// `() => ref.invalidate(theProvider)` or a notifier `.refresh()`).
class HeroErrorView extends StatelessWidget {
  const HeroErrorView({
    super.key,
    this.title,
    this.onRetry,
    this.icon = Icons.cloud_off,
    this.compact = false,
  });

  /// User-facing message. Defaults to the generic l10n error.
  final String? title;

  /// When non-null, a retry button is shown.
  final VoidCallback? onRetry;

  final IconData icon;

  /// Tighter padding / smaller icon for embedding inside cards or lists.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 36 : 52,
              color: const Color(0xB3FFFFFF),
            ),
            SizedBox(height: compact ? 10 : 16),
            Text(
              title ?? l.errorGeneric,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: compact ? 13 : 15),
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 12 : 20),
              HeroButton(
                label: l.commonRetry,
                variant: HeroButtonVariant.secondary,
                size: HeroButtonSize.sm,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
