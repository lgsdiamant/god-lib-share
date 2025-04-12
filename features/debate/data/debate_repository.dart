import 'package:cloud_firestore/cloud_firestore.dart';

class DebateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 토론자 메시지 보내기
  Future<void> sendMessage(String roomId, String messageContent) async {
    final messageRef = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('messages')
        .doc();
    await messageRef.set({
      'content': messageContent,
      'senderType': 'debater',
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
      'senderType': 'observer',
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

  // AI 평가 요청
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

  // ✅ 토론자 신청하기
  Future<void> applyDebater(
      String roomId, String userId, String stance, String message) async {
    final applicationRef = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('applications')
        .doc(userId);

    await applicationRef.set({
      'userId': userId,
      'stance': stance,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ 토론자 신청 수락
  Future<void> acceptDebater(String roomId, String userId) async {
    final roomRef = _firestore.collection('debate_rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);
      final currentDebaters =
          (snapshot.data()?['debaters'] as List?)?.cast<String>() ?? [];
      transaction.update(roomRef, {
        'debaters': [...currentDebaters, userId],
      });
      final applicationRef = roomRef.collection('applications').doc(userId);
      transaction.update(applicationRef, {'status': 'accepted'});
    });
  }

  // ✅ 토론자 신청 거절
  Future<void> rejectDebater(String roomId, String userId) async {
    final applicationRef = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('applications')
        .doc(userId);

    await applicationRef.update({'status': 'rejected'});
  }

  // ✅ 알림 메시지 보내기
  Future<void> sendApplicationNotification(
      String roomId, String userId, String message) async {
    final messageRef = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'content': message,
      'senderType': 'system',
      'targetUserId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 추가
  // debate_repository.dart 에 추가할 것

// 신청 수락
  Future<void> acceptApplication(
      String roomId, String userId, String stance) async {
    final roomRef = _firestore.collection('debate_rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);
      final roomData = roomSnapshot.data();
      if (roomData == null) return;

      final debaters = List<String>.from(roomData['debaters'] ?? []);
      final selectedStances =
          Map<String, String>.from(roomData['selectedStances'] ?? {});

      debaters.add(userId);
      selectedStances[userId] = stance;

      transaction.update(roomRef, {
        'debaters': debaters,
        'selectedStances': selectedStances,
      });

      final applicationRef = roomRef.collection('applications').doc(userId);
      transaction.update(applicationRef, {'status': 'accepted'});
    });
  }

// 신청 거절
  Future<void> rejectApplication(String roomId, String userId) async {
    final applicationRef = _firestore
        .collection('debate_rooms')
        .doc(roomId)
        .collection('applications')
        .doc(userId);

    await applicationRef.update({'status': 'rejected'});
  }
}
