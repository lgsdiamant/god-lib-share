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
  final _roomTitleController = TextEditingController();
  List<TextEditingController> _stanceControllers = [];

  bool _isPrivate = false;
  bool _isLoading = false;
  int _participantCount = 2;
  int _maxObservers = 0;
  bool _isUnlimitedObservers = true;

  String? _mySelectedStance; // ✅ 본인 입장 선택 상태

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.topicTitle;
    _descriptionController.text = widget.topicDescription;
    _roomTitleController.text = '토론-${widget.topicTitle}';

    _stanceControllers = widget.stances.isNotEmpty
        ? widget.stances
            .map((stance) => TextEditingController(text: stance))
            .toList()
        : [
            TextEditingController(text: '찬성합니다.'),
            TextEditingController(text: '반대합니다.'),
          ];

    _mySelectedStance =
        _stanceControllers.isNotEmpty ? _stanceControllers.first.text : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _roomTitleController.dispose();
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
    final roomTitle = _roomTitleController.text.trim();
    final stances = _stanceControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (title.isEmpty || stances.length < 2 || _mySelectedStance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 입장 2개 이상, 본인 입장을 선택하세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('debate_rooms').add({
        'createdBy': createdBy,
        'title': title,
        'roomTitle': roomTitle,
        'description': description,
        'stances': stances,
        'debaters': [createdBy],
        'observers': [],
        'selectedStances': {
          createdBy: _mySelectedStance, // ✅ 방장의 입장 저장
        },
        'participantCount': _participantCount,
        'maxObservers': _isUnlimitedObservers ? -1 : _maxObservers,
        'isPrivate': _isPrivate,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
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
      _mySelectedStance = _stanceControllers.first.text; // ✅ 드롭다운도 갱신
    });
  }

  void _removeStance(int index) {
    if (_stanceControllers.length <= 2) return;
    setState(() {
      _stanceControllers.removeAt(index);
      _mySelectedStance = _stanceControllers.isNotEmpty
          ? _stanceControllers.first.text
          : null; // ✅ 드롭다운도 갱신
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('토론방 만들기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('토론방 생성하기'),
              onPressed: _createRoom,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roomTitleController,
              decoration: const InputDecoration(labelText: '토론방 제목'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '주제 제목'),
              enabled: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '주제 설명'),
              enabled: true,
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
                      onChanged: (_) {
                        setState(() {
                          // 🔥 텍스트가 바뀌었을 때도 드롭다운 리스트 갱신
                          _mySelectedStance = _stanceControllers
                                  .map((c) => c.text.trim())
                                  .where((text) => text.isNotEmpty)
                                  .contains(_mySelectedStance)
                              ? _mySelectedStance
                              : (_stanceControllers.isNotEmpty
                                  ? _stanceControllers.first.text
                                  : null);
                        });
                      },
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

            // ✅ 나의 입장 선택
            const Text('나의 입장 선택',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _mySelectedStance,
              isExpanded: true,
              items: _stanceControllers.map((controller) {
                final stance = controller.text;
                return DropdownMenuItem(
                  value: stance,
                  child: Text(stance),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _mySelectedStance = value;
                });
              },
            ),
            const SizedBox(height: 24),

            const Text('토론 인원수', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _participantCount,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 2, child: Text('1:1 토론')),
                DropdownMenuItem(value: 3, child: Text('3자 토론')),
                DropdownMenuItem(value: 4, child: Text('2:2 토론')),
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

            const Text('관전자 설정', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Checkbox(
                  value: _isUnlimitedObservers,
                  onChanged: (value) {
                    setState(() {
                      _isUnlimitedObservers = value ?? true;
                      if (_isUnlimitedObservers) {
                        _maxObservers = 0;
                      } else {
                        _maxObservers = 10;
                      }
                    });
                  },
                ),
                const Text('무제한 관전자'),
              ],
            ),
            if (!_isUnlimitedObservers)
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '최대 관전자 수 (0은 불가)'),
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
    );
  }
}
