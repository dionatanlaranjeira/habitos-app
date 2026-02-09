import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/core.dart';
import '../models/category_model.dart';
import 'category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepositoryImpl({required FirestoreAdapter firestore})
    : _firestore = firestore.instance;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final query = await _firestore
        .collection('categories')
        .orderBy('order')
        .get();

    return query.docs
        .map((doc) => CategoryModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
