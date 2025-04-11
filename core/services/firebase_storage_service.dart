import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../error/app_exception.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 프로필 이미지를 Storage에 업로드
  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw AppException('프로필 이미지 업로드 실패: ${e.toString()}');
    }
  }
}
