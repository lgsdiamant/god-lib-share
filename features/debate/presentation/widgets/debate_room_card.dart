import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DebateRoomCard extends StatelessWidget {
  final QueryDocumentSnapshot room;

  const DebateRoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final roomId = room.id;
    final title = room['title'] ?? '제목 없음';
    final description = room['description'] ?? '설명 없음';
    final hostNickname = room['hostNickname'] ?? '방장';
    final status = room['status'] ?? 'unknown';
    final createdAt = (room['createdAt'] as Timestamp?)?.toDate();
    final debaters = (room['debaters'] as List?)?.length ?? 0;
    final observers = (room['observers'] as List?)?.length ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
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
            Text('개설자: $hostNickname'),
            const SizedBox(height: 4),
            Text('토론자: $debaters명 | 관전자: $observers명'),
            const SizedBox(height: 4),
            Text('상태: ${_translateStatus(status)}'),
            if (createdAt != null) ...[
              const SizedBox(height: 4),
              Text('개설일: ${createdAt.toLocal().toString().substring(0, 10)}'),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.push('/debate-room/$roomId');
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
