import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/core/constants/constants.dart';
import 'package:god_of_debate/core/constants/constants_keys.dart';
import 'package:god_of_debate/core/constants/constants_string.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/firebase_providers.dart';

class ProfileViewScreen extends ConsumerWidget {
  final String uid; // ✅ 특정 사용자 UID

  const ProfileViewScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(firebaseAuthProvider);
    final firestore = ref.read(firebaseFirestoreProvider);
    final currentUid = auth.currentUser?.uid;

    final isMyProfile = uid == currentUid; // ✅ 현재 로그인된 사용자인지 판단

    return Scaffold(
      appBar: AppBar(
        title: const Text(strProfileViewTitle),
        actions: [
          if (isMyProfile) // ✅ 본인일 경우에만 수정 버튼
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/profile-edit');
              },
            ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection(kUsersCollection).doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('프로필 정보를 찾을 수 없습니다.'));
          }

          final profile = snapshot.data!.data() as Map<String, dynamic>;
          final isPhonePublic = profile['isPhonePublic'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profile[kFieldPhotoUrl] != null && profile[kFieldPhotoUrl] != ''
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profile[kFieldPhotoUrl]),
                      )
                    : const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이름: ${profile[kFieldName] ?? ''}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('닉네임: ${profile[kFieldNickname] ?? ''}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('한줄 소개: ${profile[kFieldBio] ?? ''}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('좋아하는 토론 주제: ${profile[kFieldFavoriteTopic] ?? ''}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('성별: ${profile[kFieldGender] ?? ''}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('나이대: ${profile[kFieldAgeGroup] ?? ''}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      if (isPhonePublic) // ✅ 전화번호 공개 동의 시에만 보여줌
                        Text('전화번호: ${profile[kFieldPhone] ?? ''}',
                            style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
