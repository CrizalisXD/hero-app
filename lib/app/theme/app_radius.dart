/// Corner-radius scale for the Hero design system.
///
/// Convention:
/// - [xs] / [s]  → bars, chips, small pills, progress tracks
/// - [m] / [l]   → cards and panels (default surface = [l])
/// - [xl]        → bottom sheets / dialogs
/// - [pill]      → fully rounded (FAB, stadium buttons, avatars)
class AppRadius {
  AppRadius._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double pill = 999;
}
