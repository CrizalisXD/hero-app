import 'models/achievement.dart';
import 'models/user_achievement.dart';

abstract class AchievementsRepository {
  Future<List<Achievement>> listAll();
  Future<List<UserAchievement>> listMyUnlocked();
}
