// lib/features/user/application/user_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNicknameProvider =
    FutureProvider.family<String, String>((ref, uid) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snapshot.data();
    return data?['nickname'] ?? '알 수 없음';
  } catch (e) {
    return '알 수 없음';
  }
});
