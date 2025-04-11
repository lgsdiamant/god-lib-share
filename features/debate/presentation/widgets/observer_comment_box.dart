import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

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
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '관찰자로서 코멘트를 남겨주세요',
                border: OutlineInputBorder(),
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
