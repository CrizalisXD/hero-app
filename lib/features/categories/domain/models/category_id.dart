/// 7 canonical categories from TZ §7.1.
/// Wire format must match `task_category` enum in DB and `id` in categories.json.
enum CategoryId {
  strength,
  mind,
  endurance,
  health,
  social,
  finance,
  creativity;

  String get wire => name;

  static CategoryId? fromWire(String? raw) {
    if (raw == null) return null;
    for (final v in CategoryId.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}
