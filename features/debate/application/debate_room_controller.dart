import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/debate_repository.dart';

class DebateRoomController {
  final String roomId;
  final WidgetRef ref;

  late final DebateRepository _debateRepository;

  DebateRoomController(this.roomId, this.ref) {
    _debateRepository = DebateRepository();
  }

  Future<void> initialize() async {
    // 방 초기화 작업
    // 예: 방 정보 불러오기, 필요한 초기 데이터 설정
  }

  void sendMessage(String messageContent) async {
    if (messageContent.trim().isEmpty) return;

    await _debateRepository.sendMessage(roomId, messageContent);
  }

  void sendObserverComment(String commentContent) async {
    if (commentContent.trim().isEmpty) return;

    await _debateRepository.sendObserverComment(roomId, commentContent);
  }

  void voteForDebater(String debaterId) async {
    await _debateRepository.voteForDebater(roomId, debaterId);
  }

  void requestAiEvaluation() async {
    await _debateRepository.requestAiEvaluation(roomId);
  }

  void endDebate() async {
    await _debateRepository.endDebate(roomId);
  }

  void dispose() {
    // 필요 시 Controller 클린업 작업
  }
}
