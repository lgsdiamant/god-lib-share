import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _markAsRead(String messageId) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(_uid)
        .collection('userMessages')
        .doc(messageId)
        .update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림센터'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(_uid)
            .collection('userMessages')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data?.docs ?? [];

          if (messages.isEmpty) {
            return const Center(child: Text('알림이 없습니다.'));
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final title = message['title'] ?? '알림';
              final content = message['content'] ?? '';
              final isRead = message['isRead'] ?? false;
              final messageId = message.id;

              return ListTile(
                leading: Icon(
                  isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                  color: isRead ? Colors.grey : Colors.blue,
                ),
                title: Text(title),
                subtitle: Text(content),
                onTap: () {
                  if (!isRead) {
                    _markAsRead(messageId);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
