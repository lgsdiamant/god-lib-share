import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/constants.dart';
import '../../user/application/user_providers.dart'; // ✅ 닉네임 Provider
import '../application/debate_room_controller.dart'; // ✅ 신청 수락/거절 로직

class DebateApplicationsScreen extends ConsumerWidget {
  final String roomId;

  const DebateApplicationsScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsStream = FirebaseFirestore.instance
        .collection('debate_rooms')
        .doc(roomId)
        .collection('applications')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('신청 관리'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: applicationsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('신청한 사용자가 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final userId = data['uid'] ?? '';
              final stance = data['stance'] ?? '';
              final message = data['message'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Consumer(
                    builder: (context, ref, _) {
                      final nicknameAsync =
                          ref.watch(userNicknameProvider(userId));
                      return nicknameAsync.when(
                        data: (nickname) =>
                            Text('닉네임: $nickname'), // ✅ 그냥 텍스트로 보여주기만
                        loading: () => const Text('불러오는 중...'),
                        error: (_, __) => const Text('닉네임 불러오기 실패'),
                      );
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('입장: $stance'),
                      const SizedBox(height: 4),
                      Text('메시지: $message'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: '수락',
                          onPressed: () =>
                              _respondToApplication(context, userId, true),
                        ),
                      ),
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: '거절',
                          onPressed: () =>
                              _respondToApplication(context, userId, false),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _respondToApplication(
      BuildContext context, String userId, bool accepted) async {
    try {
      final applicationsRef = FirebaseFirestore.instance
          .collection('debate_rooms')
          .doc(roomId)
          .collection('applications')
          .doc(userId);

      // 1. 신청 문서 상태 업데이트
      await applicationsRef.update({
        'status': accepted ? 'accepted' : 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      if (accepted) {
        // 2. ✅ 수락이면 debate_rooms.debaters에 추가
        final roomRef =
            FirebaseFirestore.instance.collection('debate_rooms').doc(roomId);
        await roomRef.update({
          'debaters': FieldValue.arrayUnion([userId]),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accepted ? '수락하고 토론자에 추가했습니다.' : '거절했습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리 실패')),
      );
    }
  }
}
