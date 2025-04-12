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
    final isObserver = senderType == 'observer';
    final isSystem = senderType == 'system';

    Color backgroundColor;
    Alignment alignment;
    if (isDebater) {
      backgroundColor = Colors.blue.shade100;
      alignment = Alignment.centerLeft;
    } else if (isObserver) {
      backgroundColor = Colors.grey.shade300;
      alignment = Alignment.centerLeft;
    } else {
      backgroundColor = Colors.orange.shade100;
      alignment = Alignment.center;
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSystem) // 시스템 메시지는 발신자 정보 생략
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blueGrey.shade200,
                    child: Text(
                      senderName.isNotEmpty ? senderName[0] : '?',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    timestamp,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            if (!isSystem) const SizedBox(height: 6),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: isSystem ? Colors.deepOrange : Colors.black87,
                fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
