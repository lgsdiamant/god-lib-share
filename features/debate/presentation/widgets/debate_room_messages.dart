import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/core/widgets/loading_indicator.dart';
import 'package:god_of_debate/features/debate/application/debate_providers.dart';
import 'chat_bubble.dart';

class DebateRoomMessages extends ConsumerWidget {
  final String roomId;

  const DebateRoomMessages({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(debateMessagesProvider(roomId));

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return const Center(child: Text('아직 메시지가 없습니다.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return ChatBubble(message: message);
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('메시지 로딩 실패: $e')),
    );
  }
}
