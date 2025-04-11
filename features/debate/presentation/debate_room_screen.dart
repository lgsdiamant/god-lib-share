import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../application/debate_room_controller.dart';
import '../application/debate_providers.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/debate_chat_widget.dart';
import 'widgets/observer_comment_box.dart';
import 'widgets/viewer_vote_button.dart';

class DebateRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const DebateRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<DebateRoomScreen> createState() => _DebateRoomScreenState();
}

class _DebateRoomScreenState extends ConsumerState<DebateRoomScreen> {
  late final DebateRoomController _controller;
  String? _selectedDebaterId; // ✅ 선택한 토론자 ID를 저장하는 상태

  @override
  void initState() {
    super.initState();
    _controller = DebateRoomController(widget.roomId, ref);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debateRoomAsync = ref.watch(debateRoomProvider(widget.roomId));
    final messagesAsync = ref.watch(debateMessagesProvider(widget.roomId));
    final votesAsync = ref.watch(debateVotesProvider(widget.roomId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('토론방'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'AI 평가 요청',
            onPressed: _controller.requestAiEvaluation,
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            tooltip: '토론 종료',
            onPressed: _controller.endDebate,
          ),
        ],
      ),
      body: debateRoomAsync.when(
        data: (room) {
          final debaters = (room['debaters'] as List?)?.cast<String>() ?? [];

          return Column(
            children: [
              _buildRoomInfo(room),
              const Divider(),
              Expanded(
                child: messagesAsync.when(
                  data: (messages) => ListView.builder(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => Center(child: Text('채팅 로딩 실패: $e')),
                ),
              ),
              const Divider(),
              DebateChatWidget(onSend: _controller.sendMessage),
              ObserverCommentBox(onComment: _controller.sendObserverComment),
              const SizedBox(height: 8),
              _buildDebaterVoteSection(debaters), // ✅ 토론자 투표 버튼들
              const SizedBox(height: 8),
              votesAsync.when(
                data: (votes) => _buildVoteResult(votes),
                loading: () => const LoadingIndicator(),
                error: (e, _) => Text('투표 결과 로딩 실패: $e'),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('토론방 정보를 불러올 수 없습니다: $e')),
      ),
    );
  }

  Widget _buildRoomInfo(Map<String, dynamic> room) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room['title'] ?? '제목 없음',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            room['description'] ?? '설명 없음',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('상태: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(room['status'] ?? '알 수 없음'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebaterVoteSection(List<String> debaters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: debaters.map((debaterId) {
        final isSelected = _selectedDebaterId == debaterId;
        return ViewerVoteButton(
          debateRoomId: widget.roomId,
          voterId: 'currentUserId', // 🔥 실제 로그인된 유저 ID로 교체 필요
          targetDebaterId: debaterId,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedDebaterId = debaterId;
            });
            _controller.voteForDebater(debaterId);
          },
        );
      }).toList(),
    );
  }

  Widget _buildVoteResult(Map<String, int> votes) {
    if (votes.isEmpty) {
      return const Text('아직 투표가 없습니다.');
    }

    return Column(
      children: votes.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '${entry.key}: ${entry.value}표',
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }
}
