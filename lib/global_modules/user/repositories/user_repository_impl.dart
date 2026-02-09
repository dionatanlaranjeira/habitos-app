import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/core.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

const _usersCollection = 'users';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required FirestoreAdapter firestore})
      : _firestore = firestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_usersCollection);

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _ref.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _ref.doc(user.uid).set(user.toFirestore());
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _ref.doc(uid).update(data);
  }
}
