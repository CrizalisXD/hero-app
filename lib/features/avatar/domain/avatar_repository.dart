import 'models/avatar.dart';

abstract class AvatarRepository {
  Future<Avatar> getMine();
  Future<Avatar> updatePrimaryColor(String hex);
}
