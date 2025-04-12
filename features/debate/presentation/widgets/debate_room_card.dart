// lib/features/debate/presentation/widgets/debate_room_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:god_of_debate/core/utils/user_utils.dart';

class DebateRoomCard extends StatelessWidget {
  final QueryDocumentSnapshot room;

  const DebateRoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final roomId = room.id;
    final title = room['roomTitle'] ?? room['title'] ?? '제목 없음';
    final description = room['description'] ?? '설명 없음';
    final createdByUid = room['createdBy'] ?? '방장';
    final status = room['status'] ?? 'unknown';
    final createdAt = (room['createdAt'] as Timestamp?)?.toDate();
    final debaters = (room['debaters'] as List?)?.length ?? 0;
    final observers = (room['observers'] as List?)?.length ?? 0;
    final stances = (room['stances'] as List?)?.cast<String>() ?? [];
    final selectedStances = (room['selectedStances'] as Map?) ?? {};

    // 남은 입장 계산
    final takenStances = selectedStances.values.toSet();
    final availableStances =
        stances.where((stance) => !takenStances.contains(stance)).toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: FutureBuilder<String>(
        future: fetchNickname(createdByUid), // ✅ 닉네임 가져오는 Future
        builder: (context, snapshot) {
          final nickname = snapshot.data ?? '방장'; // 가져오기 전이면 기본값

          return ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('방장: $nickname',
                    style: const TextStyle(fontSize: 13)), // ✅ 여기 nickname 사용
                const SizedBox(height: 4),
                Text('토론자 수: $debaters명  |  관전자 수: $observers명',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('진행 상태: ${_translateStatus(status)}',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                if (availableStances.isNotEmpty)
                  Text(
                    '남은 입장: ${availableStances.join(', ')}',
                    style: const TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                      '개설일: ${createdAt.toLocal().toString().substring(0, 10)}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/debate-room-detail/$roomId');
            },
          );
        },
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'waiting':
        return '대기중';
      case 'active':
        return '진행중';
      case 'closed':
        return '종료됨';
      default:
        return '알 수 없음';
    }
  }
}
