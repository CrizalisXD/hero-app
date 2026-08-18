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
  late final CurvedAnimation _glowCurve;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowCurve = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(_glowCurve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncGlow();
  }

  @override
  void didUpdateWidget(QuestMapNode old) {
    super.didUpdateWidget(old);
    _syncGlow();
  }

  /// Пульс крутится, только когда он действительно нужен: нода активна и ОС не
  /// просит убрать анимации. Пока он идёт, Flutter не уходит в простой и
  /// вынужден каждый кадр пересобирать оверлеи поверх Unity-платформвью —
  /// поэтому лишний кадр здесь стоит дороже, чем на обычном экране.
  void _syncGlow() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final shouldAnimate = widget.isActive && !reduceMotion;
    if (shouldAnimate && !_glowCtrl.isAnimating) {
      _glowCtrl.repeat(reverse: true);
    } else if (!shouldAnimate && _glowCtrl.isAnimating) {
      _glowCtrl.stop();
      if (reduceMotion) _glowCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _glowCurve.dispose();
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
                // Пульсирующее свечение вынесено в ОТДЕЛЬНЫЙ слой под орбом.
                // Размытие радиусом 34 растеризуется один раз (RepaintBoundary),
                // а каждый кадр меняется только opacity готового слоя — это
                // работа GPU, без перерисовки блюра на CPU. Раньше блюр
                // перерисовывался 60 раз в секунду, и поверх Unity-платформвью
                // это был самый дорогой элемент экрана.
                if (widget.isActive)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: FadeTransition(
                          opacity: _glowAnim,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.65),
                                  blurRadius: 34,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Сам орб теперь полностью статичен — ни одного перестроения
                // за кадр. Свечение активной ноды рисует слой выше.
                Container(
                  height: widget.size,
                  width: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isActive
                        ? RadialGradient(
                            center: const Alignment(-0.35, -0.45),
                            radius: 1.1,
                            colors: [
                              Color.lerp(activeColor, Colors.white, 0.45)!,
                              activeColor,
                              Color.lerp(activeColor, Colors.black, 0.30)!,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          )
                        : RadialGradient(
                            center: const Alignment(-0.4, -0.5),
                            radius: 1.15,
                            colors: [
                              Color.lerp(
                                activeColor,
                                const Color(0xFF16161E),
                                0.42,
                              )!,
                              const Color(0xFF15151D),
                              const Color(0xFF0B0B11),
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                    border: widget.isActive
                        ? null
                        : Border.all(
                            color: activeColor.withValues(alpha: 0.9),
                            width: 2.5,
                          ),
                    // Активной ноде тень здесь больше не нужна: её рисует
                    // кэшированный пульсирующий слой под орбом.
                    boxShadow: widget.isActive
                        ? null
                        : [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.42),
                              blurRadius: 20,
                            ),
                          ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isActive ? Colors.white : activeColor,
                    size: widget.size * 0.40,
                  ),
                ),
                // Specular glint — turns the flat disc into a glossy orb.
                Positioned(
                  top: widget.size * 0.12,
                  left: widget.size * 0.22,
                  child: IgnorePointer(
                    child: Container(
                      width: widget.size * 0.56,
                      height: widget.size * 0.28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.size),
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
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
