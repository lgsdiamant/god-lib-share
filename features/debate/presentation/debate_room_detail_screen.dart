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
    final title = room['roomTitle'] ?? room['title'] ?? '제목 없음';
    final description = room['description'] ?? '';
    final createdAt = (room['createdAt'] as Timestamp?)?.toDate();
    final isPrivate = room['isPrivate'] ?? false;
    final maxObservers = room['maxObservers'] ?? -1;
    final stances = (room['stances'] as List?)?.cast<String>() ?? [];
    final participantCount = room['participantCount'] ?? 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('토론방 상세정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('토론방 제목', title),
            _buildInfoCard(
                '주제 설명', description.isNotEmpty ? description : '설명 없음'),
            _buildInfoCard(
                '입장 옵션', stances.isNotEmpty ? stances.join(' / ') : '없음'),
            _buildInfoCard(
                '토론 참가 인원', _translateParticipantCount(participantCount)),
            _buildInfoCard('공개 여부', isPrivate ? '🔒 비공개' : '🌐 공개'),
            _buildInfoCard(
                '관전자 제한', maxObservers == -1 ? '무제한' : '$maxObservers명'),
            _buildInfoCard(
                '개설일',
                createdAt != null
                    ? createdAt.toLocal().toString().substring(0, 10)
                    : '알 수 없음'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _joinDebate(context),
                style: kButtonStyle,
                icon: const Icon(Icons.login),
                label: const Text('토론방 입장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  String _translateParticipantCount(int count) {
    switch (count) {
      case 2:
        return '1:1 토론';
      case 3:
        return '3자 토론';
      case 4:
        return '2:2 토론 또는 4자 토론';
      default:
        return '$count명 토론';
    }
  }
}
