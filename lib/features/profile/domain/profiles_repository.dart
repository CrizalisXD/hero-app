import 'profile_snapshot.dart';

abstract class ProfilesRepository {
  Future<ProfileSnapshot> getMyProfile();
}
