import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Live HH:MM:SS countdown that ticks once per second.
///
/// Self-contained so callers don't have to manage a Ticker — drop in
/// the [endAt] and it disposes its own Timer when removed. Falls back
/// to "—" once the deadline passes (status pill handles the finished
/// case visually).
class ChallengeCountdown extends StatefulWidget {
  const ChallengeCountdown({
    super.key,
    required this.endAt,
    this.style,
  });

  final DateTime endAt;
  final TextStyle? style;

  @override
  State<ChallengeCountdown> createState() => _ChallengeCountdownState();
}

class _ChallengeCountdownState extends State<ChallengeCountdown> {
  Timer? _ticker;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endAt.difference(DateTime.now());
    // Only tick while a positive remaining time exists; once finished
    // we just sit on the final frame to avoid wasted setStates.
    if (!_remaining.isNegative) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final next = widget.endAt.difference(DateTime.now());
        if (next.isNegative) {
          _ticker?.cancel();
          _ticker = null;
        }
        setState(() => _remaining = next);
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChallengeCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endAt != widget.endAt) {
      _ticker?.cancel();
      _remaining = widget.endAt.difference(DateTime.now());
      if (!_remaining.isNegative) {
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            _remaining = widget.endAt.difference(DateTime.now());
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d.isNegative) return '—';
    String two(int v) => v.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${two(hours)} : ${two(minutes)} : ${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(_remaining),
      style: widget.style ??
          const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.warning,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
    );
  }
}
