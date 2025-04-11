import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/debate_room_card.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../application/debate_providers.dart';

class WaitingDebateRoomsScreen extends ConsumerWidget {
  const WaitingDebateRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitingRoomsAsync = ref.watch(waitingDebateRoomsProvider);
    final activeRoomsAsync = ref.watch(activeDebateRoomsProvider);
    final closedRoomsAsync = ref.watch(closedDebateRoomsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('토론방 찾기'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '대기 중'),
              Tab(text: '진행 중'),
              Tab(text: '종료됨'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRoomList(context, waitingRoomsAsync),
            _buildRoomList(context, activeRoomsAsync),
            _buildRoomList(context, closedRoomsAsync),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateOrSelectOptions(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildRoomList(BuildContext context,
      AsyncValue<List<QueryDocumentSnapshot>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return const Center(child: Text('토론방이 없습니다.'));
        }
        return ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return DebateRoomCard(room: room);
            });
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('오류 발생: $e')),
    );
  }

  void _showCreateOrSelectOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.create),
                title: const Text('새 주제 만들기'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/create-topic');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('기존 주제 선택'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/select-topic');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
