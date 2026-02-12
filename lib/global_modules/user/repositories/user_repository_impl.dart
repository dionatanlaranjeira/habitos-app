import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/core.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

const _usersCollection = 'users';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required FirestoreAdapter firestore,
    required StorageAdapter storage,
  }) : _firestore = firestore.instance,
       _storage = storage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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

  @override
  Future<String> uploadProfilePicture(String uid, String filePath) async {
    final ref = _storage.ref().child('users').child(uid).child('profile.jpg');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
