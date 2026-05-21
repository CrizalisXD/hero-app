enum TaskDifficulty {
  easy,
  normal,
  hard,
  epic;

  String get wire => name;

  static TaskDifficulty fromWire(String? raw) =>
      values.firstWhere(
        (e) => e.name == raw,
        orElse: () => TaskDifficulty.normal,
      );
}

enum TaskDuration {
  short,
  medium,
  long;

  String get wire => name;

  static TaskDuration fromWire(String? raw) =>
      values.firstWhere(
        (e) => e.name == raw,
        orElse: () => TaskDuration.medium,
      );
}

enum TaskImportance {
  low,
  normal,
  high;

  String get wire => name;

  static TaskImportance fromWire(String? raw) =>
      values.firstWhere(
        (e) => e.name == raw,
        orElse: () => TaskImportance.normal,
      );
}
