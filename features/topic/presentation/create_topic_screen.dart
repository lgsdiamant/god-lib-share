import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';

class CreateTopicScreen extends ConsumerStatefulWidget {
  const CreateTopicScreen({super.key});

  @override
  ConsumerState<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends ConsumerState<CreateTopicScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;
  bool _isTitleValid = false; // ✅ 제목 유효성 체크 추가
  List<TextEditingController> _stanceControllers = [];

  @override
  void initState() {
    super.initState();
    _stanceControllers = [
      TextEditingController(text: '찬성합니다.'),
      TextEditingController(text: '반대합니다.'),
    ];
    _titleController.addListener(_validateTitle); // ✅ 제목 리스너 등록
  }

  void _validateTitle() {
    setState(() {
      _isTitleValid = _titleController.text.trim().length >= 5;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_validateTitle); // ✅ 리스너 해제
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _stanceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveTopic() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final stances = _stanceControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (title.length < 5 || stances.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주제 제목은 5자 이상, 입장은 2개 이상 입력하세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('topics').add({
        'title': title,
        'description': description,
        'isPublic': _isPublic,
        'approved': false,
        'createdBy': 'userId123', // ✅ 실제 로그인된 사용자 ID로 교체 예정
        'stances': stances,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주제가 저장되었습니다! 대화방을 만들어주세요.')),
      );

      context.push('/create-debate-room', extra: {
        'title': title,
        'description': description,
        'stances': stances,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('주제 저장 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addStance() {
    if (_stanceControllers.length >= 4) return;
    setState(() {
      _stanceControllers.add(TextEditingController());
    });
  }

  void _removeStance(int index) {
    if (_stanceControllers.length <= 2) return;
    setState(() {
      _stanceControllers.removeAt(index);
    });
  }

  void _cancelCreation() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 주제 만들기'),
        actions: [
          TextButton(
            onPressed: _cancelCreation,
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '주제 제목',
                  hintText: '주제 제목을 5자 이상 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '주제 설명',
                  hintText: '주제를 보충 설명할 수 있습니다 (선택사항)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('입장 관리 (최소 2개, 최대 4개)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ..._stanceControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: '입장을 입력하세요 (예: 찬성합니다)',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _stanceControllers.length > 2
                          ? () => _removeStance(index)
                          : null,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              if (_stanceControllers.length < 4)
                TextButton.icon(
                  onPressed: _addStance,
                  icon: const Icon(Icons.add),
                  label: const Text('입장 추가'),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('공개 여부:'),
                  const SizedBox(width: 8),
                  DropdownButton<bool>(
                    value: _isPublic,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('공개')),
                      DropdownMenuItem(value: false, child: Text('비공개')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _isPublic = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: kButtonStyle,
                        onPressed:
                            _isTitleValid ? _saveTopic : null, // ✅ 제목 유효성 검사
                        child: const Text('주제 저장 후 대화방 만들기'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
