import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorage _storage;

  StorageRepositoryImpl({required FirebaseStorage storage})
    : _storage = storage;

  @override
  Future<String> uploadPhoto({required String path, required File file}) async {
    final compressed = await _compressImage(file);
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(
      compressed,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  Future<File> _compressImage(File file) async {
    return await compute(_compressInIsolate, file.path).then((bytes) {
      final compressedFile = File('${file.path}_compressed.jpg');
      compressedFile.writeAsBytesSync(bytes);
      return compressedFile;
    });
  }

  static Uint8List _compressInIsolate(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Redimensionar se maior que 1024px
    final resized = image.width > 1024
        ? img.copyResize(image, width: 1024)
        : image;

    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }
}
