import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:god_of_debate/core/providers/firebase_providers.dart';
import '../../../core/constants/constants.dart';

class CreateDebateRoomScreen extends ConsumerStatefulWidget {
  final String topicTitle;
  final String topicDescription;
  final List<String> stances;

  const CreateDebateRoomScreen({
    super.key,
    required this.topicTitle,
    required this.topicDescription,
    required this.stances,
  });

  @override
  ConsumerState<CreateDebateRoomScreen> createState() =>
      _CreateDebateRoomScreenState();
}

class _CreateDebateRoomScreenState
    extends ConsumerState<CreateDebateRoomScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<TextEditingController> _stanceControllers = [];
  bool _isPrivate = false;
  bool _isLoading = false;
  bool _isUnlimitedObservers = true; // ✅ 관전자 무제한
  int _participantCount = 2;
  int _maxObservers = 10; // ✅ 기본 10명 (무제한 해제 시)

  String? _selectedStance; // ✅ 내가 선택한 입장

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.topicTitle;
    _descriptionController.text = widget.topicDescription;

    _stanceControllers = widget.stances.isNotEmpty
        ? widget.stances
            .map((stance) => TextEditingController(text: stance))
            .toList()
        : [
            TextEditingController(text: '찬성합니다.'),
            TextEditingController(text: '반대합니다.'),
          ];

    _selectedStance = _stanceControllers.first.text; // ✅ default 입장 선택
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _stanceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _createRoom() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    final createdBy = user?.uid;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final stances = _stanceControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (title.isEmpty || stances.length < 2 || _selectedStance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 입장 2개 이상, 입장 선택을 해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('debate_rooms').add({
        'createdBy': createdBy,
        'title': title,
        'description': description,
        'stances': stances,
        'participantCount': _participantCount,
        'maxObservers': _isUnlimitedObservers ? -1 : _maxObservers,
        'isPrivate': _isPrivate,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'debaters': [createdBy], // ✅ 나 자신
        'observers': [], // ✅ 비어있게
        'selectedStances': {
          createdBy!: _selectedStance,
        }, // ✅ 나의 입장
      });

      if (!mounted) return;
      context.go('/debate-rooms');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('토론방 만들기')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createRoom,
                style: kButtonStyle,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('토론방 생성하기'),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
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
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: '토론방 설명'),
                  ),
                  const SizedBox(height: 24),
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
                              hintText: '입장을 입력하세요',
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
                  const SizedBox(height: 24),
                  const Text('내 입장 선택',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _stanceControllers.map((c) {
                      final stance = c.text;
                      return ChoiceChip(
                        label: Text(stance),
                        selected: _selectedStance == stance,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedStance = stance;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('토론 인원수',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                    value: _participantCount,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('1:1 토론')),
                      DropdownMenuItem(value: 4, child: Text('2:2 토론')),
                      DropdownMenuItem(value: 3, child: Text('3자 토론')),
                      DropdownMenuItem(value: 4, child: Text('4자 토론')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _participantCount = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('관전자 수 설정',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Checkbox(
                        value: _isUnlimitedObservers,
                        onChanged: (value) {
                          setState(() {
                            _isUnlimitedObservers = value ?? true;
                          });
                        },
                      ),
                      const Text('관전자 수 무제한'),
                    ],
                  ),
                  if (!_isUnlimitedObservers)
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '최대 관전자 수 입력 (기본 10명)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _maxObservers = int.tryParse(value) ?? 10;
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
                  const SizedBox(height: 8),
                  Text(
                    _isPrivate
                        ? '🔒 비공개: 초대한 관전자만 참여할 수 있어요.'
                        : '🌐 공개: 누구나 관전할 수 있어요.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
