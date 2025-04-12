import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/features/debate/presentation/widgets/debate_timer';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../application/debate_room_controller.dart';
import '../application/debate_providers.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/observer_comment_box.dart';

class DebateRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const DebateRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<DebateRoomScreen> createState() => _DebateRoomScreenState();
}

class _DebateRoomScreenState extends ConsumerState<DebateRoomScreen> {
  late final DebateRoomController _controller;

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

    return debateRoomAsync.when(
      data: (room) {
        final roomTitle = room['roomTitle'] ?? room['title'] ?? '토론방';
        final topicTitle = room['title'] ?? '주제 없음';
        final topicDescription = room['description'] ?? '';
        final createdAt = (room['createdAt'] as Timestamp?)?.toDate();

        return Scaffold(
          appBar: AppBar(
            title: Text(roomTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.flag),
                tooltip: 'AI 평가 요청',
                onPressed: _controller.requestAiEvaluation,
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                tooltip: '나가기',
                onPressed: () {
                  Navigator.pop(context); // ✅ 임시로 홈으로
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatusBar(room), // ✅ 상태바
              _buildTimer(createdAt), // ✅ 타이머
              _buildTopicCard(topicTitle, topicDescription),
              Expanded(
                child: Stack(
                  children: [
                    _buildChatArea(messagesAsync),
                    _buildObserverCommentBox(votesAsync),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => Scaffold(
        body: Center(child: Text('토론방 정보를 불러올 수 없습니다: $e')),
      ),
    );
  }

  Widget _buildStatusBar(Map<String, dynamic> room) {
    final status = room['status'] ?? 'waiting';
    String statusText;

    switch (status) {
      case 'waiting':
        statusText = '⏳ 대기 중입니다. 토론 시작을 기다리는 중...';
        break;
      case 'active':
        statusText = '🔥 토론이 진행 중입니다!';
        break;
      case 'closed':
        statusText = '🏁 토론이 종료되었습니다.';
        break;
      default:
        statusText = '알 수 없음';
    }

    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          statusText,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTimer(DateTime? createdAt) {
    if (createdAt == null) return const SizedBox();

    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DebateTimer(startTime: createdAt), // ✅ 여기 고쳤어
    );
  }

  Widget _buildTopicCard(String title, String description) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Text(description),
        ),
      ],
    );
  }

  Widget _buildChatArea(AsyncValue<List<Map<String, dynamic>>> messagesAsync) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // ✅ 댓글창 높이만큼
      child: messagesAsync.when(
        data: (messages) {
          return ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatBubble(message: message);
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('채팅 로딩 실패: $e')),
      ),
    );
  }

  Widget _buildObserverCommentBox(AsyncValue<Map<String, int>> votesAsync) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ObserverCommentBox(
                onComment: _controller.sendObserverComment,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.poll),
              tooltip: '투표현황',
              onPressed: () {
                _showVoteDialog(votesAsync);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVoteDialog(AsyncValue<Map<String, int>> votesAsync) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('투표 현황'),
          content: votesAsync.when(
            data: (votes) {
              if (votes.isEmpty) {
                return const Text('아직 투표가 없습니다.');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: votes.entries.map((entry) {
                  return ListTile(
                    title: Text('${entry.key}: ${entry.value}표'),
                  );
                }).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('투표 로딩 실패: $e'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
