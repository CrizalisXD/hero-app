import 'package:flutter/material.dart';

/// Hero design system colors.
///
/// Source of truth for all category, accent, semantic and rarity colors.
/// Aligned with the 7 canonical categories from the new TЗ:
/// strength, mind, endurance, health, social, finance, creativity.
class AppColors {
  AppColors._();

  // ── Background ──
  static const Color bg = Color(0xFF0D0D12);
  static const Color bgCard = Color(0xFF16161E);
  static const Color bgElevated = Color(0xFF1E1E2A);
  static const Color bgSheet = Color(0xFF1A1A24);

  // ── Accent ──
  static const Color accent = Color(0xFF7F77DD);
  static const Color accentDim = Color(0x407F77DD);
  static const Color accentGlow = Color(0x207F77DD);
  static const Color accentBright = Color(0xFFB967FF);

  // ── Gradients (hero moments: XP bar, level-up, FAB, premium CTAs) ──
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7F77DD), Color(0xFFB967FF)],
  );
  static const LinearGradient xpGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7F77DD), Color(0xFFB967FF), Color(0xFFFFB86C)],
  );
  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF39C12), Color(0xFFFFD93D)],
  );
  static const LinearGradient energyLowGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE74C3C), Color(0xFFF39C12)],
  );

  // ── Neon Arcade (gamified identity — pilot on Home) ──
  static const Color neonViolet = Color(0xFF8B7BFF);
  static const Color neonMagenta = Color(0xFFC264FF);
  static const Color energyAmber = Color(0xFFFF8A3D);
  static const Color neonCyan = Color(0xFF29E5D4);

  /// Signature brand gradient — the "glue" of the gamified look. Use on
  /// hero moments: XP bar, level, primary CTAs, active states.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF8B7BFF), Color(0xFFC264FF), Color(0xFFFF9A3D)],
  );

  /// Stronger neon glow for the arcade treatment (vs the subtle accentGlow).
  static const Color neonGlow = Color(0x558B7BFF);

  // ── Rarity tiers (loot/items/streak badges) ──
  static const Color rarityCommon = Color(0xFF8A8A95);
  static const Color rarityRare = Color(0xFF3498DB);
  static const Color rarityEpic = Color(0xFFB967FF);
  static const Color rarityLegendary = Color(0xFFFFB86C);

  /// Tier ring color for level milestones (used around avatar).
  static List<Color> levelTierGradient(int level) {
    if (level >= 50) {
      return const [Color(0xFFFFB86C), Color(0xFFFF6E6E)];
    }
    if (level >= 25) {
      return const [Color(0xFFB967FF), Color(0xFF7F77DD)];
    }
    if (level >= 10) {
      return const [Color(0xFF3498DB), Color(0xFF7F77DD)];
    }
    return const [Color(0xFF8B7BFF), Color(0xFFC264FF)];
  }

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x80FFFFFF);
  static const Color textDisabled = Color(0x33FFFFFF);

  // ── Categories (must match assets/data/categories.json) ──
  static const Color strength = Color(0xFFE54B4B);
  static const Color mind = Color(0xFF5B6CFF);
  static const Color endurance = Color(0xFF23B07A);
  static const Color health = Color(0xFF3DC9C2);
  static const Color social = Color(0xFFFFB547);
  static const Color finance = Color(0xFFF2C94C);
  static const Color creativity = Color(0xFFBF7CFF);

  /// Meta-stat (discipline / consistency / focus) accent.
  /// Single muted gold so meta-XP toasts stand apart from category XP visually.
  static const Color disciplineMeta = Color(0xFFD4AF37);

  // ── Semantic ──
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // ── Task Difficulty ──
  static const Color easy = Color(0xFF2ECC71);
  static const Color normal = Color(0xFF3498DB);
  static const Color hard = Color(0xFFF39C12);
  static const Color epic = Color(0xFFE74C3C);

  // ── Habit Type ──
  static const Color goodHabit = Color(0xFF2ECC71);
  static const Color badHabit = Color(0xFFE74C3C);

  // ── Borders / Dividers ──
  static const Color border = Color(0x1AFFFFFF);
  static const Color divider = Color(0x0DFFFFFF);

  /// Returns the brand color for a task category wire string.
  ///
  /// Pass one of: strength, mind, endurance, health, social, finance, creativity.
  /// Unknown values fall back to [accent] so the UI never crashes on stale data.
  static Color categoryColor(String category) {
    switch (category) {
      case 'strength':
        return strength;
      case 'mind':
        return mind;
      case 'endurance':
        return endurance;
      case 'health':
        return health;
      case 'social':
        return social;
      case 'finance':
        return finance;
      case 'creativity':
        return creativity;
      default:
        return accent;
    }
  }
}
