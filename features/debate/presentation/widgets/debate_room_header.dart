import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/features/debate/application/debate_providers.dart';
import 'package:god_of_debate/features/debate/presentation/widgets/debate_timer';

class DebateRoomHeader extends ConsumerWidget {
  final String roomId;
  final DateTime startTime;

  const DebateRoomHeader({
    super.key,
    required this.roomId,
    required this.startTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(debateRoomProvider(roomId));

    return roomAsync.when(
      data: (room) {
        final hostUid = room['createdBy'] ?? '';
        final debaters = (room['debaters'] as List?)?.cast<String>() ?? [];
        final observers = (room['observers'] as List?)?.cast<String>() ?? [];
        final status = room['status'] ?? 'waiting';

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 20, color: Colors.black54),
                  const SizedBox(width: 8),
                  DebateTimer(startTime: startTime),
                  const Spacer(),
                  Text(
                    _translateStatus(status),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  _buildInfoIcon(Icons.person, '방장: $hostUid'),
                  const SizedBox(width: 16),
                  _buildInfoIcon(Icons.group, '토론자 ${debaters.length}명'),
                  const SizedBox(width: 16),
                  _buildInfoIcon(Icons.visibility, '관전자 ${observers.length}명'),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 50),
      error: (e, _) => Text('정보 불러오기 실패: $e'),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'waiting':
        return '대기 중';
      case 'active':
        return '토론 진행 중';
      case 'closed':
        return '종료됨';
      default:
        return '상태 알 수 없음';
    }
  }
}
