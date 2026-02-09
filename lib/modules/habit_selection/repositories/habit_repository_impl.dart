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
    // Tenta buscar do cache/banco
    final snapshot = await _ref.orderBy('order').get();

    return snapshot.docs
        .map((doc) => HabitModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
