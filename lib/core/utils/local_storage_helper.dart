import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageHelper {
  final FlutterSecureStorage? _storage;

  LocalStorageHelper(this._storage);

  Future<void> writeString(String key, String value) async =>
      await _storage?.write(key: key, value: value);

  Future<String?> readString(String key) async =>
      await _storage?.read(key: key);

  Future<void> clearSaved() async => await _storage?.deleteAll();
}
