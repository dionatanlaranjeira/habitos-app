import 'package:firebase_storage/firebase_storage.dart';

/// Adapter para acesso ao Firebase Storage.
/// Centraliza a instância e permite injeção para testes.
class StorageAdapter {
  StorageAdapter() : _storage = FirebaseStorage.instance;

  final FirebaseStorage _storage;
  FirebaseStorage get instance => _storage;
}
