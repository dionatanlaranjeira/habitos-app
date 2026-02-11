import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/core.dart';
import '../models/habit_model.dart';
import 'habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final FirebaseFirestore _firestore;

  HabitRepositoryImpl({required FirestoreAdapter firestore})
    : _firestore = firestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection('habits');

  @override
  Future<List<HabitModel>> getHabitLibrary() async {
    try {
      // Tenta buscar do cache primeiro para velocidade
      final cacheSnapshot = await _ref
          .orderBy('order')
          .get(const GetOptions(source: Source.cache));

      if (cacheSnapshot.docs.isNotEmpty) {
        return cacheSnapshot.docs
            .map((doc) => HabitModel.fromFirestore(doc.id, doc.data()))
            .toList();
      }
    } catch (_) {
      // Ignora erro de cache e vai para o server
    }

    // Se não tiver cache ou der erro, busca do servidor
    final snapshot = await _ref.orderBy('order').get();

    return snapshot.docs
        .map((doc) => HabitModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> saveMemberHabits({
    required String groupId,
    required String userId,
    required List<String> habitIds,
  }) async {
    final batch = _firestore.batch();

    final memberRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId);

    batch.set(memberRef, {
      'userId': userId,
      'selectedHabitIds': habitIds,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Também atualizar o array de memberIds no documento do grupo por segurança
    final groupRef = _firestore.collection('groups').doc(groupId);
    batch.update(groupRef, {
      'memberIds': FieldValue.arrayUnion([userId]),
    });

    await batch.commit();
  }
}
