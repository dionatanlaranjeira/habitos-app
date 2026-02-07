import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class LocalSecureStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<bool> contains(String key);

  Future<void> clear();

  Future<void> remove(String key);
}

class LocalSecureStorageImpl implements LocalSecureStorage {
  FlutterSecureStorage get _instance => FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  @override
  Future<void> clear() => _instance.deleteAll();

  @override
  Future<bool> contains(String key) => _instance.containsKey(key: key);

  @override
  Future<String?> read(String key) => _instance.read(key: key);

  @override
  Future<void> remove(String key) => _instance.delete(key: key);

  @override
  Future<void> write(String key, String value) =>
      _instance.write(key: key, value: value);
}
