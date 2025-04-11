import 'package:cloud_firestore/cloud_firestore.dart';

class DebateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 채팅 메시지 보내기
  Future<void> sendMessage(String roomId, String messageContent) async {
    final messageRef = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'content': messageContent,
      'senderType': 'debater', // 토론자 메시지
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 관찰자 코멘트 보내기
  Future<void> sendObserverComment(String roomId, String commentContent) async {
    final messageRef = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'content': commentContent,
      'senderType': 'observer', // 관찰자 메시지
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 토론자에게 투표하기
  Future<void> voteForDebater(String roomId, String debaterId) async {
    final voteDoc = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('votes')
        .doc('voteResult');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(voteDoc);

      if (!snapshot.exists) {
        transaction.set(voteDoc, {debaterId: 1});
      } else {
        final currentVotes = snapshot.data() ?? {};
        final currentCount = (currentVotes[debaterId] ?? 0) as int;
        transaction.update(voteDoc, {debaterId: currentCount + 1});
      }
    });
  }

  // AI 평가 요청 기록
  Future<void> requestAiEvaluation(String roomId) async {
    final roomRef = _firestore.collection('debate_rooms').doc(roomId);

    await roomRef.update({
      'aiEvaluationRequested': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 토론 종료
  Future<void> endDebate(String roomId) async {
    final roomRef = _firestore.collection('debate_rooms').doc(roomId);

    await roomRef.update({
      'status': 'closed',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }
}
