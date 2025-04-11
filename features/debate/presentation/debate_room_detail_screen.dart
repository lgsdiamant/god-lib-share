import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';

class DebateRoomDetailScreen extends ConsumerWidget {
  final DocumentSnapshot room;

  const DebateRoomDetailScreen({super.key, required this.room});

  void _joinDebate(BuildContext context) {
    final roomId = room.id;
    context.go('/debate-room/$roomId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = room['title'] ?? '제목 없음';
    final description = room['description'] ?? '';
    final createdAt = (room['createdAt'] as Timestamp?)?.toDate();
    final isPrivate = room['isPrivate'] ?? false;
    final maxAudience = room['maxAudience'] ?? 0;
    final debateType = room['debateType'] ?? '토론';

    return Scaffold(
      appBar: AppBar(
        title: const Text('토론방 상세정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제목: $title',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('설명: $description', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('토론 종류: $debateType', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('공개 여부: ${isPrivate ? '비공개' : '공개'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('관전자 제한: ${maxAudience == 0 ? '무제한' : '$maxAudience 명'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
                '개설일: ${createdAt != null ? createdAt.toLocal().toString().substring(0, 10) : '알 수 없음'}',
                style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _joinDebate(context),
                style: kButtonStyle,
                child: const Text('참여하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
