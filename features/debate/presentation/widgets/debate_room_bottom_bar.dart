import 'package:flutter/material.dart';

class DebateRoomBottomBar extends StatelessWidget {
  final bool isHost;
  final VoidCallback onLeaveRoom;
  final VoidCallback onStartDebate;
  final VoidCallback onEndDebate;

  const DebateRoomBottomBar({
    super.key,
    required this.isHost,
    required this.onLeaveRoom,
    required this.onStartDebate,
    required this.onEndDebate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.exit_to_app,
            label: '나가기',
            onPressed: onLeaveRoom,
          ),
          if (isHost) ...[
            _buildIconButton(
              icon: Icons.play_arrow,
              label: '토론 시작',
              onPressed: onStartDebate,
            ),
            _buildIconButton(
              icon: Icons.stop_circle,
              label: '토론 종료',
              onPressed: onEndDebate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          tooltip: label,
          color: Colors.black87,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
