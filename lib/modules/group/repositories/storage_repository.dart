import 'dart:io';

abstract class StorageRepository {
  Future<String> uploadPhoto({required String path, required File file});
}
