import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:god_of_debate/core/providers/firebase_providers.dart';
import '../../../core/constants/constants.dart';
import '../../user/application/user_providers.dart'; // ✅ 추가
import '../application/debate_room_controller.dart'; // ✅ 추가

class DebateRoomDetailScreen extends ConsumerStatefulWidget {
  final DocumentSnapshot room;

  const DebateRoomDetailScreen({super.key, required this.room});

  @override
  ConsumerState<DebateRoomDetailScreen> createState() =>
      _DebateRoomDetailScreenState();
}

class _DebateRoomDetailScreenState
    extends ConsumerState<DebateRoomDetailScreen> {
  late final DebateRoomController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DebateRoomController(widget.room.id, ref);
  }

  void _showApplyDebaterDialog() {
    final stances = (widget.room['stances'] as List?)?.cast<String>() ?? [];

    String? selectedStance;
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('토론자로 신청하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                items: stances.map((stance) {
                  return DropdownMenuItem(
                    value: stance,
                    child: Text(stance),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedStance = value;
                },
                decoration: const InputDecoration(
                  labelText: '입장을 선택하세요',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: '인사 메시지',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStance == null ||
                    messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('입장과 메시지를 모두 입력하세요.')),
                  );
                  return;
                }
                await _controller.applyAsDebater(
                    selectedStance!, messageController.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('토론자 신청을 보냈습니다.')),
                  );
                }
              },
              child: const Text('신청하기'),
            ),
          ],
        );
      },
    );
  }

  void _confirmEnterAsObserver() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('관전자로 입장'),
          content: const Text('관전자로 입장하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _controller.enterAsObserver();
                if (mounted) {
                  Navigator.pop(context);
                  context.go('/debate-room/${widget.room.id}');
                }
              },
              child: const Text('입장하기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHost = (widget.room['createdBy'] ==
        ref.read(firebaseAuthProvider).currentUser?.uid);

    final room = widget.room; // ✅
    final roomId = room.id; // ✅ 추가

    final title = room['roomTitle'] ?? room['title'] ?? '제목 없음';
    final description = room['description'] ?? '';
    final createdAt = (room['createdAt'] as Timestamp?)?.toDate();
    final isPrivate = room['isPrivate'] ?? false;
    final maxObservers = room['maxObservers'] ?? -1;
    final stances = (room['stances'] as List?)?.cast<String>() ?? [];
    final participantCount = room['participantCount'] ?? 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('토론방 상세정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text('토론자로 신청하기'),
                    onPressed: _showApplyDebaterDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text('관전자로 입장하기'),
                    onPressed: _confirmEnterAsObserver,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildInfoCard('토론방 제목', title),
                  _buildInfoCard(
                      '주제 설명', description.isNotEmpty ? description : '설명 없음'),
                  _buildInfoCard(
                      '입장 옵션', stances.isNotEmpty ? stances.join(' / ') : '없음'),
                  _buildInfoCard(
                      '토론 참가 인원', _translateParticipantCount(participantCount)),
                  _buildInfoCard('공개 여부', isPrivate ? '🔒 비공개' : '🌐 공개'),
                  _buildInfoCard(
                      '관전자 제한', maxObservers == -1 ? '무제한' : '$maxObservers명'),
                  _buildInfoCard(
                      '개설일',
                      createdAt != null
                          ? createdAt.toLocal().toString().substring(0, 10)
                          : '알 수 없음'),
                  const Spacer(),
                  // debate_room_detail_screen.dart 에 추가할 것
// 방장이라면 신청 관리 버튼 보이기
                  if (isHost)
                    ElevatedButton(
                      onPressed: () {
                        context.push('/debate-applications/$roomId');
                      },
                      child: const Text('신청 관리'),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  String _translateParticipantCount(int count) {
    switch (count) {
      case 2:
        return '1:1 토론';
      case 3:
        return '3자 토론';
      case 4:
        return '2:2 토론';
      default:
        return '$count명 토론';
    }
  }
}
