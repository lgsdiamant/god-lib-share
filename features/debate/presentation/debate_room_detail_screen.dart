import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../user/application/user_providers.dart'; // ✅ 닉네임 가져오는 Provider
import '../application/debate_room_controller.dart'; // ✅ 신청/입장 로직
import '../application/debate_providers.dart'; // ✅ debateRoomProvider

class DebateRoomDetailScreen extends ConsumerStatefulWidget {
  final String roomId; // ✅ 이제는 roomId만 받아

  const DebateRoomDetailScreen({super.key, required this.roomId});

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
    _controller = DebateRoomController(widget.roomId, ref);
  }

  void _showApplyDebaterDialog(List<String> stances) {
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
                  labelText: '주장을 선택하세요',
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
                    const SnackBar(content: Text('주장과 메시지를 모두 입력하세요.')),
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
                  context.go('/debate-room/${widget.roomId}');
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
    final roomAsync = ref.watch(debateRoomProvider(widget.roomId));

    return roomAsync.when(
      data: (room) {
        final title = room['roomTitle'] ?? room['title'] ?? '제목 없음';
        final description = room['description'] ?? '';
        final createdAt = (room['createdAt'] as Timestamp?)?.toDate();
        final stances = (room['stances'] as List?)?.cast<String>() ?? [];
        final participantCount = room['participantCount'] ?? 2;
        final maxObservers = room['maxObservers'] ?? -1;
        final isPrivate = room['isPrivate'] ?? false;
        final createdBy = room['createdBy'] ?? '';
        final debaters = (room['debaters'] as List?)?.cast<String>() ?? [];
        final observers = (room['observers'] as List?)?.cast<String>() ?? [];
        final status = room['status'] ?? 'waiting';

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
                        label: const Text('토론자로 신청'),
                        onPressed: status == 'waiting'
                            ? () => _showApplyDebaterDialog(stances)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.remove_red_eye),
                        label: const Text('관전자로 입장'),
                        onPressed: () => _confirmEnterAsObserver(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildInfoCard('토론방 제목', title),
                      _buildInfoCard('주제 설명', description),
                      _buildInfoCard('참가 주장', stances.join(' / ')),
                      _buildInfoCard('개설자 UID', createdBy),
                      _buildInfoCard('토론자 수', '${debaters.length}명'),
                      _buildInfoCard('관전자 수', '${observers.length}명'),
                      _buildInfoCard('토론 상태', _translateStatus(status)),
                      _buildInfoCard(
                          '개설일',
                          createdAt != null
                              ? createdAt.toLocal().toString().substring(0, 16)
                              : '알 수 없음'),
                      _buildInfoCard('관전자 제한',
                          maxObservers == -1 ? '무제한' : '$maxObservers명'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('토론방 정보를 불러올 수 없습니다: $e')),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'waiting':
        return '대기 중';
      case 'active':
        return '진행 중';
      case 'closed':
        return '종료됨';
      default:
        return '알 수 없음';
    }
  }
}
