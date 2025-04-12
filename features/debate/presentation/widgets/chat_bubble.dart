import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final content = message['content'] ?? '';
    final senderType = message['senderType'] ?? 'observer';
    final senderName = message['senderName'] ?? 'Unknown';
    final timestamp = (message['timestamp'] as String?) ?? '';

    final isDebater = senderType == 'debater';
    final isHost = message['isHost'] ?? false;

    return Align(
      alignment: isDebater
          ? (isHost ? Alignment.centerRight : Alignment.centerLeft)
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDebater
              ? (isHost ? Colors.blue.shade100 : Colors.green.shade100)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blueGrey.shade200,
                  child: Text(senderName.isNotEmpty ? senderName[0] : '?'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  timestamp,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              content,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
