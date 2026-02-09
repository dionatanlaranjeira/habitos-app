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
}
