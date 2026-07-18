import '../../categories/domain/models/category_id.dart';

/// Каноническая мечта — одна запись на всех, кто её хочет.
///
/// Намеренно не хранит ничего личного: «хочу» конкретного человека, его
/// заметки и фото живут в [DreamFollow]. Иначе общий справочник стал бы
/// местом утечки приватного.
///
/// Три числа здесь принципиально разной природы, поэтому не сведены в одну
/// «звёздность»:
///   • [wantCount] — солидарность («тоже хочу»), накручивается одним тапом;
///   • [difficultyAvg] — мнение сообщества о сложности;
///   • [worthAvg] — «стоило того», право на который даёт только факт, что
///     человек это сделал (БД стережёт через ck_worth_requires_done).
class Dream {
  const Dream({
    required this.id,
    required this.title,
    required this.wantCount,
    required this.doneCount,
    required this.difficultyVotes,
    required this.worthVotes,
    required this.createdAt,
    this.category,
    this.difficultyAvg,
    this.worthAvg,
  });

  final String id;
  final String title;

  /// null, когда классификатор не был уверен. UI обязан пережить это без
  /// дырки в вёрстке — чип категории просто не показывается.
  final CategoryId? category;

  final int wantCount;
  final int doneCount;

  /// null, пока никто не голосовал за сложность.
  final double? difficultyAvg;
  final int difficultyVotes;

  /// null, пока никто из сделавших не оценил. Отличается от «оценка 0» —
  /// «ещё никто не пробовал» это приглашение стать первым, а не низкая оценка.
  final double? worthAvg;
  final int worthVotes;

  final DateTime createdAt;

  bool get isTriedByAnyone => doneCount > 0;

  factory Dream.fromJson(Map<String, dynamic> j) => Dream(
        id: j['id'] as String,
        title: j['title'] as String,
        category: CategoryId.fromWire(j['category'] as String?),
        wantCount: (j['want_count'] as num?)?.toInt() ?? 0,
        doneCount: (j['done_count'] as num?)?.toInt() ?? 0,
        difficultyAvg: (j['difficulty_avg'] as num?)?.toDouble(),
        difficultyVotes: (j['difficulty_votes'] as num?)?.toInt() ?? 0,
        worthAvg: (j['worth_avg'] as num?)?.toDouble(),
        worthVotes: (j['worth_votes'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
