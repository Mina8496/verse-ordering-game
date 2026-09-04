import 'dart:typed_data';

abstract interface class ProfileImageUploader {
  Future<String?> upload(Uint8List bytes);
}