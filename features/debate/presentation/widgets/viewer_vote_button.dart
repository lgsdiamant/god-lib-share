import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewerVoteButton extends ConsumerWidget {
  final String debateRoomId;
  final String voterId;
  final String targetDebaterId;
  final bool isSelected;
  final VoidCallback onTap;

  const ViewerVoteButton({
    super.key,
    required this.debateRoomId,
    required this.voterId,
    required this.targetDebaterId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade300 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.favorite : Icons.favorite_border,
              color: isSelected ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 8),
            const Text(
              '당신이 더 잘하고 있어!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
