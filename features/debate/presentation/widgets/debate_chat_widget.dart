import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class DebateChatWidget extends StatefulWidget {
  final void Function(String) onSend; // ✅ 콜백 받기

  const DebateChatWidget({super.key, required this.onSend});

  @override
  State<DebateChatWidget> createState() => _DebateChatWidgetState();
}

class _DebateChatWidgetState extends State<DebateChatWidget> {
  final TextEditingController _controller = TextEditingController();

  void _submitMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text); // ✅ 입력된 텍스트를 콜백으로 전달
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitMessage,
          ),
        ],
      ),
    );
  }
}
