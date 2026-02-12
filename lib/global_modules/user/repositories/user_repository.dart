import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUser(String uid);
  Future<void> createUser(UserModel user);
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Future<String> uploadProfilePicture(String uid, String filePath);
}
