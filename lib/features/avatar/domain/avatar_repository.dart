import 'models/avatar.dart';
import 'models/avatar_asset.dart';

abstract class AvatarRepository {
  /// Сохранённая конфигурация текущего пользователя.
  Future<Avatar> getMine();

  /// Каталог доступных предметов. Read-only, общий для всех пользователей.
  Future<AvatarCatalog> fetchCatalog();

  /// Атомарно сохраняет всю конфигурацию одной RPC. Возвращает канонический
  /// результат сервера: он мог заменить несовместимые слоты дефолтами.
  Future<Avatar> saveConfig(Avatar avatar);

  Future<Avatar> updatePrimaryColor(String hex);
}
