import 'package:flutter/material.dart';

class ObserverCommentBox extends StatefulWidget {
  final void Function(String) onComment;

  const ObserverCommentBox({super.key, required this.onComment});

  @override
  State<ObserverCommentBox> createState() => _ObserverCommentBoxState();
}

class _ObserverCommentBoxState extends State<ObserverCommentBox> {
  final TextEditingController _controller = TextEditingController();
  bool _isWriting = false;

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onComment(text);
    _controller.clear();
    setState(() {
      _isWriting = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (_isWriting)
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _isWriting = value.isNotEmpty;
                  });
                },
                onSubmitted: (_) => _submitComment(),
              ),
            )
          else
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isWriting = true;
                  });
                },
                child:
                    const Text('관전자로 댓글 작성하기', style: TextStyle(fontSize: 16)),
              ),
            ),
          if (_isWriting) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ]
        ],
      ),
    );
  }
}
