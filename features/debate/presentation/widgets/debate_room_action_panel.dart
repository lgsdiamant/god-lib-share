import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/features/debate/application/debate_room_controller.dart';

class DebateRoomActionPanel extends ConsumerWidget {
  final String roomId;

  const DebateRoomActionPanel({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = DebateRoomController(roomId, ref);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('토론자로 신청'),
                onPressed: () =>
                    _showDebaterApplicationDialog(context, controller),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.remove_red_eye),
                label: const Text('관전자로 입장'),
                onPressed: () async {
                  final confirmed =
                      await _showConfirmDialog(context, '관전자로 입장하시겠습니까?');
                  if (confirmed) {
                    await controller.enterAsObserver();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDebaterApplicationDialog(
      BuildContext context, DebateRoomController controller) async {
    final stanceController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('토론자로 신청하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stanceController,
                decoration: const InputDecoration(
                  labelText: '희망하는 주장',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: '인사 메시지',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (stanceController.text.isNotEmpty &&
                    messageController.text.isNotEmpty) {
                  await controller.applyAsDebater(
                    stanceController.text.trim(),
                    messageController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('토론자 신청을 보냈습니다!')),
                    );
                  }
                }
              },
              child: const Text('신청하기'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('확인'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('확인'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
