import 'package:flutter/material.dart';

class DebateRoomActions extends StatelessWidget {
  final VoidCallback onLeave;
  final VoidCallback onRequestMidEvaluation;
  final VoidCallback onEndDebate;
  final bool isHost;
  final bool isDebater;

  const DebateRoomActions({
    super.key,
    required this.onLeave,
    required this.onRequestMidEvaluation,
    required this.onEndDebate,
    required this.isHost,
    required this.isDebater,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            tooltip: '나가기',
            onPressed: onLeave,
          ),
          if (isHost)
            IconButton(
              icon: const Icon(Icons.flag, color: Colors.orange),
              tooltip: '중간 평가 요청',
              onPressed: onRequestMidEvaluation,
            ),
          if (isHost)
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.black),
              tooltip: '토론 종료',
              onPressed: onEndDebate,
            ),
        ],
      ),
    );
  }
}
