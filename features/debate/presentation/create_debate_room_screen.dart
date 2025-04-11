import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:god_of_debate/core/constants/constants_keys.dart';
import '../../../core/constants/constants.dart';

class CreateDebateRoomScreen extends ConsumerStatefulWidget {
  final String topicTitle;
  final String topicDescription;

  const CreateDebateRoomScreen({
    super.key,
    required this.topicTitle,
    required this.topicDescription,
  });

  @override
  ConsumerState<CreateDebateRoomScreen> createState() =>
      _CreateDebateRoomScreenState();
}

class _CreateDebateRoomScreenState
    extends ConsumerState<CreateDebateRoomScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _participantCount = 2; // ✅ 기본 1:1 토론
  bool _isPrivate = false;
  int _maxObservers = 0; // 0이면 무제한
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.topicTitle;
    _descriptionController.text = widget.topicDescription;
  }

  Future<void> _createRoom() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 설명을 모두 입력하세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection(kDebateRoomsCollection).add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'participantCount': _participantCount,
        'maxObservers': _maxObservers,
        'isPrivate': _isPrivate,
        'status': 'waiting', // 대기중 상태
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('토론방 생성 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('토론방 만들기'), // ✅ 하드코딩
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '토론방 제목'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '토론방 설명'),
            ),
            const SizedBox(height: 24),
            const Text('토론 인원 수',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _participantCount,
              isExpanded: true,
              items: [2, 3, 4]
                  .map((count) =>
                      DropdownMenuItem(value: count, child: Text('$count명')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _participantCount = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('최대 관전자 수 (0=무제한)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: '최대 관전자 수 입력 (0 = 무제한)'),
              onChanged: (value) {
                setState(() {
                  _maxObservers = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('비공개 토론방',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createRoom,
                      style: kButtonStyle,
                      child: const Text('토론방 생성하기'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
