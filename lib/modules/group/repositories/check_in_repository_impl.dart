import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/core.dart';
import '../models/models.dart';
import 'check_in_repository.dart';
import 'storage_repository.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final FirebaseFirestore _firestore;
  final StorageRepository _storageRepository;

  CheckInRepositoryImpl({
    required FirestoreAdapter firestore,
    required StorageRepository storageRepository,
  }) : _firestore = firestore.instance,
       _storageRepository = storageRepository;

  CollectionReference<Map<String, dynamic>> _checkInsRef(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('checkins');

  @override
  Future<void> submitCheckIn({
    required String groupId,
    required String userId,
    required String habitId,
    required String date,
    required File photo,
    String? description,
  }) async {
    // 1. Upload da foto comprimida
    final storagePath = 'checkins/$groupId/$userId/$date/$habitId.jpg';
    final photoUrl = await _storageRepository.uploadPhoto(
      path: storagePath,
      file: photo,
    );

    // 2. Salvar check-in no Firestore
    await _checkInsRef(groupId).add({
      'userId': userId,
      'habitId': habitId,
      'date': date,
      'photoUrl': photoUrl,
      'description': description ?? '',
      'completedAt': FieldValue.serverTimestamp(),
      'points': 1,
    });
  }

  @override
  Future<List<CheckInModel>> getCheckInsByDate({
    required String groupId,
    required String date,
  }) async {
    final snapshot = await _checkInsRef(
      groupId,
    ).where('date', isEqualTo: date).get();

    return snapshot.docs
        .map((doc) => CheckInModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<CheckInModel>> getCheckInsByUserAndDate({
    required String groupId,
    required String userId,
    required String date,
  }) async {
    final snapshot = await _checkInsRef(
      groupId,
    ).where('userId', isEqualTo: userId).where('date', isEqualTo: date).get();

    return snapshot.docs
        .map((doc) => CheckInModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
