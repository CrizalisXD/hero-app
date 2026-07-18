import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/dreams_notifier.dart';

/// Фирменный розовый мечт — совпадает с орбом «Хочу попробовать» на Home.
const _pink = Color(0xFFFF6FB5);

/// Карточка мечты в списке. Три числа разной природы, поэтому и выглядят
/// по-разному: «стоило того» подсвечено зелёным, потому что его нельзя
/// накрутить — оно заработано теми, кто сделал.
class DreamCardTile extends StatelessWidget {
  const DreamCardTile({
    super.key,
    required this.card,
    required this.onWant,
    required this.onOpen,
    this.onLongPress,
  });

  final DreamCard card;
  final VoidCallback onWant;
  final VoidCallback onOpen;

  /// Долгое нажатие — меню действий (в цель / в челлендж) прямо из списка.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = card.dream;
    final accent = card.isMine ? _pink : AppColors.accent;

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onOpen,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: accent, width: 2)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.25,
                      ),
                    ),
                  ),
                  _WantButton(active: card.isMine, onTap: onWant),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Stat(
                    icon: Icons.people_outline,
                    value: _fmt(d.wantCount),
                    label: l.dreamsStatWant,
                  ),
                  const SizedBox(width: 16),
                  _Stat(
                    icon: Icons.terrain_outlined,
                    value: d.difficultyAvg?.toStringAsFixed(1) ?? '—',
                    label: l.dreamsStatDifficulty,
                  ),
                  const SizedBox(width: 16),
                  // «Стоило того» либо заработанная зелёная оценка, либо
                  // приглашение стать первым — но не «ноль из пяти».
                  if (d.worthAvg != null)
                    _Stat(
                      icon: Icons.star_outline,
                      value: d.worthAvg!.toStringAsFixed(1),
                      label: l.dreamsStatWorth,
                      color: AppColors.success,
                    )
                  else
                    _UnchartedTag(label: l.dreamsUncharted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(int n) {
    if (n < 1000) return '$n';
    final k = n / 1000;
    return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
  }
}

class _WantButton extends StatelessWidget {
  const _WantButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: active ? context.l10n.dreamsWantRemove : context.l10n.dreamsWant,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            active ? Icons.favorite : Icons.favorite_border,
            color: active ? _pink : AppColors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: c, fontSize: 12, height: 1)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: c.withValues(alpha: 0.7),
            fontSize: 11,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _UnchartedTag extends StatelessWidget {
  const _UnchartedTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.6),
        fontSize: 11,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
