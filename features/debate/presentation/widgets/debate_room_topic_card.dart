import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/features/debate/application/debate_providers.dart';

class DebateRoomTopicCard extends ConsumerWidget {
  final String roomId;

  const DebateRoomTopicCard({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(debateRoomProvider(roomId));

    return roomAsync.when(
      data: (room) {
        final topicTitle = room['title'] ?? '주제 없음';
        final topicDescription = room['description'] ?? '설명 없음';
        final stances = (room['stances'] as List?)?.cast<String>() ?? [];
        final selectedStances = (room['selectedStances'] as Map?) ?? {};

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              topicTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Text(
                topicDescription,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              ...stances.map((stance) {
                final takenBy = selectedStances.entries
                    .firstWhere(
                      (entry) => entry.value == stance,
                      orElse: () => const MapEntry('', ''),
                    )
                    .key;

                return ListTile(
                  leading: const Icon(Icons.arrow_right),
                  title: Text(stance),
                  subtitle: takenBy.isNotEmpty
                      ? Text('참가자: $takenBy',
                          style: const TextStyle(color: Colors.green))
                      : const Text('비어있음', style: TextStyle(color: Colors.red)),
                );
              }).toList(),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('주제 정보를 불러올 수 없습니다: $e'),
    );
  }
}
