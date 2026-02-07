import 'package:cloud_firestore/cloud_firestore.dart';

/// Adapter para acesso ao Firestore.
/// Centraliza a instância e permite injeção para testes.
class FirestoreAdapter {
  FirestoreAdapter() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  FirebaseFirestore get instance => _firestore;
}
