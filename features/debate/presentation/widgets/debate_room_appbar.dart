import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DebateRoomAppBar extends StatelessWidget {
  final Map<String, dynamic> room;

  const DebateRoomAppBar({super.key, required this.room});

  void _handleExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('토론방 나가기'),
        content: const Text('토론방을 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home'); // ✅ 홈화면으로 이동
            },
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomTitle = room['roomTitle'] ?? room['title'] ?? '토론방';

    return Container(
      color: Colors.blueAccent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.forum, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              roomTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => _handleExit(context),
          ),
        ],
      ),
    );
  }
}
