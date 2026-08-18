import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../unity/avatar_stage_config.dart';

/// Эмоция, которую герой должен проиграть, когда игрок окажется на Home.
///
/// Уровень можно поднять где угодно — в задачах, привычках, рутинах, — а живёт
/// герой только на Home. Проигрывать хлопки в тот момент, когда экран с
/// аватаром не смонтирован, некуда: анимация короткая и просто пропала бы. Так
/// что событие кладётся сюда и ждёт, пока Unity-сцена не окажется на экране и
/// не сообщит о готовности.
///
/// Очередь на одну эмоцию: два уровня подряд — это всё равно один повод
/// хлопнуть, а копить анимации, которые игрок не видел, смысла нет.
class HeroEmoteQueue extends Notifier<AvatarEmote?> {
  @override
  AvatarEmote? build() => null;

  /// Просит героя сыграть [emote] при ближайшей возможности.
  void request(AvatarEmote emote) => state = emote;

  /// Забирает эмоцию: возвращает её и очищает очередь, чтобы одно событие не
  /// проигралось дважды при пересборке виджета.
  AvatarEmote? take() {
    final pending = state;
    state = null;
    return pending;
  }

}

final heroEmoteQueueProvider =
    NotifierProvider<HeroEmoteQueue, AvatarEmote?>(HeroEmoteQueue.new);

/// Сахар для мест, где празднуется новый уровень.
void celebrateLevelUp(WidgetRef ref) =>
    ref.read(heroEmoteQueueProvider.notifier).request(AvatarEmote.levelUp);
