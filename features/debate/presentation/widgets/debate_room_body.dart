import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/core/widgets/loading_indicator.dart';
import '../../application/debate_providers.dart';
import 'debate_room_appbar.dart';

class DebateRoomBody extends ConsumerWidget {
  final String roomId;

  const DebateRoomBody({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debateRoomAsync = ref.watch(debateRoomProvider(roomId));

    return debateRoomAsync.when(
      data: (room) {
        return Column(
          children: [
            DebateRoomAppBar(room: room), // ✅ 1. 최상단 AppBar
            DebateRoomStatusBar(room: room), // ✅ 2. 상태 바 (예: 진행시간, 인원 등)
            Expanded(
              child: ChatArea(roomId: roomId), // ✅ 3. 채팅영역
            ),
            ObserverCommentArea(roomId: roomId), // ✅ 4. 관전자 전용 입력창
          ],
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('토론방을 불러올 수 없습니다: $e')),
    );
  }
}
