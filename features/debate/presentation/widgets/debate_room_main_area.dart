import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/core/widgets/loading_indicator.dart';
import '../../application/debate_providers.dart';
import 'chat_bubble.dart';
import 'observer_comment_box.dart';

class DebateRoomMainArea extends ConsumerStatefulWidget {
  final String roomId;

  const DebateRoomMainArea({super.key, required this.roomId});

  @override
  ConsumerState<DebateRoomMainArea> createState() => _DebateRoomMainAreaState();
}

class _DebateRoomMainAreaState extends ConsumerState<DebateRoomMainArea> {
  double _commentBoxHeightFactor = 0.15; // 초기 댓글 입력 영역 높이
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(debateMessagesProvider(widget.roomId));
    final votesAsync = ref.watch(debateVotesProvider(widget.roomId));

    return Stack(
      children: [
        _buildChatArea(messagesAsync),
        _buildObserverCommentBox(votesAsync),
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
            padding: const EdgeInsets.all(16),
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
            _commentBoxHeightFactor = _commentBoxHeightFactor.clamp(0.1, 0.6);
          });
        },
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            _commentBoxHeightFactor = _isExpanded ? 0.45 : 0.15;
          });
        },
        child: Container(
          height: MediaQuery.of(context).size.height * _commentBoxHeightFactor,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F8F8),
            border: Border(top: BorderSide(color: Colors.grey)),
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
                  onComment: (text) {
                    // ✅ 관전자 댓글 전송 로직 추가 예정
                  },
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
