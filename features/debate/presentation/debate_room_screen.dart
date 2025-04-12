import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  double _commentBoxHeightFactor = 0.2;
  bool _isExpanded = false;
  String? _selectedDebaterId;

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

        return Scaffold(
          appBar: AppBar(
            title: Text(roomTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.flag),
                tooltip: 'AI 중간평가',
                onPressed: _controller.requestAiEvaluation,
              ),
              IconButton(
                icon: const Icon(Icons.stop_circle),
                tooltip: '토론 종료',
                onPressed: _controller.endDebate,
              ),
            ],
          ),
          body: Column(
            children: [
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
      error: (e, _) =>
          Scaffold(body: Center(child: Text('토론방 정보를 불러올 수 없습니다: $e'))),
    );
  }

  Widget _buildTopicCard(String title, String description) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * _commentBoxHeightFactor,
      ),
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
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _commentBoxHeightFactor -=
                details.primaryDelta! / MediaQuery.of(context).size.height;
            _commentBoxHeightFactor = _commentBoxHeightFactor.clamp(0.1, 0.7);
          });
        },
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            _commentBoxHeightFactor = _isExpanded ? 0.5 : 0.2;
          });
        },
        child: Container(
          height: MediaQuery.of(context).size.height * _commentBoxHeightFactor,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F8F8),
            border: Border(
              top: BorderSide(color: Colors.grey),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ObserverCommentBox(
                  onComment: _controller.sendObserverComment,
                ),
              ),
              const Divider(),
              Expanded(
                child: votesAsync.when(
                  data: (votes) => _buildVoteResult(votes),
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => Text('투표 결과 로딩 실패: $e'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoteResult(Map<String, int> votes) {
    if (votes.isEmpty) {
      return const Center(child: Text('아직 투표가 없습니다.'));
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: votes.entries.map((entry) {
        return ListTile(
          title: Text('${entry.key} : ${entry.value}표'),
        );
      }).toList(),
    );
  }
}
