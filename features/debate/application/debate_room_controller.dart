import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../data/debate_repository.dart';

class DebateRoomController {
  final String roomId;
  final WidgetRef ref;

  late final DebateRepository _debateRepository;

  DebateRoomController(this.roomId, this.ref) {
    _debateRepository = DebateRepository();
  }

  Future<void> initialize() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('debate_rooms').doc(roomId);
    final roomSnapshot = await docRef.get();
    final roomData = roomSnapshot.data();
    if (roomData == null) return;

    final debaters = (roomData['debaters'] as List?)?.cast<String>() ?? [];

    if (!debaters.contains(user.uid)) {
      await docRef.update({
        'observers': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  void dispose() {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('debate_rooms').doc(roomId);
    docRef.update({
      'observers': FieldValue.arrayRemove([user.uid]),
    });
  }

  Future<void> sendMessage(String messageContent) async {
    if (messageContent.trim().isEmpty) return;
    await _debateRepository.sendMessage(roomId, messageContent);
  }

  Future<void> sendObserverComment(String commentContent) async {
    if (commentContent.trim().isEmpty) return;
    await _debateRepository.sendObserverComment(roomId, commentContent);
  }

  Future<void> voteForDebater(String debaterId) async {
    await _debateRepository.voteForDebater(roomId, debaterId);
  }

  Future<void> requestAiEvaluation() async {
    await _debateRepository.requestAiEvaluation(roomId);
  }

  Future<void> endDebate() async {
    await _debateRepository.endDebate(roomId);
  }

  Future<void> acceptDebater(String userId) async {
    await _debateRepository.acceptDebater(roomId, userId);
    await _debateRepository.sendApplicationNotification(
      roomId,
      userId,
      '🎉 토론자로 수락되었습니다!',
    );
  }

  Future<void> rejectDebater(String userId) async {
    await _debateRepository.rejectDebater(roomId, userId);
    await _debateRepository.sendApplicationNotification(
      roomId,
      userId,
      '😥 토론자 신청이 정중히 거절되었습니다.',
    );
  }

  Future<void> acceptApplication(
      BuildContext context, String userId, String stance) async {
    try {
      await _debateRepository.acceptApplication(roomId, userId, stance);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신청을 수락했습니다!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수락 실패: $e')),
        );
      }
    }
  }

  Future<void> rejectApplication(BuildContext context, String userId) async {
    try {
      await _debateRepository.rejectApplication(roomId, userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신청을 거절했습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('거절 실패: $e')),
        );
      }
    }
  }

  Future<void> applyAsDebater(String stance, String message) async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;

    await _debateRepository.applyDebater(
      roomId,
      user.uid,
      stance,
      message,
    );
  }

  Future<void> enterAsObserver() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('debate_rooms')
        .doc(roomId)
        .update({
      'observers': FieldValue.arrayUnion([user.uid]),
    });
  }

  /// ✅ 관전자 강제 퇴장 (예: 관전자가 직접 나가기)
  Future<void> leaveAsObserver() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('debate_rooms')
        .doc(roomId)
        .update({
      'observers': FieldValue.arrayRemove([user.uid]),
    });
  }

  /// ✅ 토론자 강제 나가기 (퇴장 요청)
  Future<void> leaveAsDebater({bool force = false}) async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('debate_rooms').doc(roomId);

    if (force) {
      // 강제 퇴장: 즉시 토론 종료로 간주
      await docRef.update({
        'status': 'incompleted',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // 정상 퇴장: 방장에게 요청 보내야함 (별도 기능 필요)
      await _debateRepository.sendApplicationNotification(
        roomId,
        user.uid,
        '⚠️ 토론자가 퇴장을 요청했습니다. 수락해주세요.',
      );
    }
  }
}
