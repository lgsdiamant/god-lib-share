import 'package:flutter/material.dart';

class DebateStatusBar extends StatelessWidget {
  final String statusMessage;

  const DebateStatusBar({super.key, required this.statusMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          const Icon(Icons.info, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusMessage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
