import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/core/constants/constants.dart';
import 'package:god_of_debate/core/constants/constants_keys.dart';
import 'package:god_of_debate/core/constants/constants_string.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/firebase_providers.dart';

class ProfileViewScreen extends ConsumerWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(firebaseAuthProvider);
    final firestore = ref.read(firebaseFirestoreProvider);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(strProfileViewTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/profile-edit');
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection(kUsersCollection).doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('프로필 정보를 찾을 수 없습니다.'));
          }

          final profile = snapshot.data!.data() as Map<String, dynamic>;

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
