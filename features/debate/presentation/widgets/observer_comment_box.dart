import 'package:flutter/material.dart';

class ObserverCommentBox extends StatefulWidget {
  final void Function(String) onComment;

  const ObserverCommentBox({super.key, required this.onComment});

  @override
  State<ObserverCommentBox> createState() => _ObserverCommentBoxState();
}

class _ObserverCommentBoxState extends State<ObserverCommentBox> {
  final TextEditingController _controller = TextEditingController();

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onComment(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }
}
