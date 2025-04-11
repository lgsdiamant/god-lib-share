// lib/features/profile/profile_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:god_of_debate/core/constants/constants_keys.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier,
    AsyncValue<Map<String, dynamic>?>>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  UserProfileNotifier() : super(const AsyncValue.loading());

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// 내 프로필 불러오기
  Future<void> fetchMyProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final doc = await _firestore.collection(kUsersCollection).doc(uid).get();
      if (doc.exists) {
        state = AsyncValue.data(doc.data());
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 프로필 수동 새로고침
  Future<void> refreshProfile() async {
    await fetchMyProfile();
  }
}
