import 'package:flutter/material.dart';

class DebateStatusBar extends StatelessWidget {
  final String statusMessage;

  const DebateStatusBar({super.key, required this.statusMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusMessage,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
