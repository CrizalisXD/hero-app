import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_colors.dart';

/// Узел квест-карты на Home-экране.
///
/// [isActive] — нода подсвечена (текущий/приоритетный раздел): золотой
/// заполненный круг с пульсирующим свечением. Иначе — тёмный «неактивный»
/// вариант с цветной рамкой.
class QuestMapNode extends StatefulWidget {
  const QuestMapNode({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.accent,
    this.badge,
    this.isActive = false,
    this.size = 60,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final String? badge;
  final bool isActive;
  final double size;

  @override
  State<QuestMapNode> createState() => _QuestMapNodeState();
}

class _QuestMapNodeState extends State<QuestMapNode>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _glowCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(QuestMapNode old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !_glowCtrl.isAnimating) {
      _glowCtrl.repeat(reverse: true);
    } else if (!widget.isActive && _glowCtrl.isAnimating) {
      _glowCtrl.stop();
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.isActive ? const Color(0xFFD4AF37) : widget.color;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, child) {
                    return Container(
                      height: widget.size,
                      width: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isActive
                            ? activeColor
                            : const Color(0xFF16161E).withValues(alpha: 0.88),
                        border: widget.isActive
                            ? null
                            : Border.all(
                                color: activeColor.withValues(alpha: 0.7),
                                width: 2.0,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(
                              alpha: widget.isActive
                                  ? 0.55 * _glowAnim.value
                                  : 0.25,
                            ),
                            blurRadius: widget.isActive ? 28 : 14,
                            spreadRadius: widget.isActive ? 4 : -2,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Icon(
                    widget.icon,
                    color: widget.isActive ? Colors.white : activeColor,
                    size: widget.size * 0.40,
                  ),
                ),
                if (widget.badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFF0D0D12),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        widget.badge!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.isActive ? Colors.white : AppColors.textSecondary,
                shadows: widget.isActive
                    ? [const Shadow(color: Colors.black54, blurRadius: 4)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
