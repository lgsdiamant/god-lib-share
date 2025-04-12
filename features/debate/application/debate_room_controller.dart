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

  // ✅ 방장이 신청 수락
  Future<void> acceptDebater(String userId) async {
    await _debateRepository.acceptDebater(roomId, userId);
    await _debateRepository.sendApplicationNotification(
      roomId,
      userId,
      '🎉 토론자로 수락되었습니다!',
    );
  }

  // ✅ 방장이 신청 거절
  Future<void> rejectDebater(String userId) async {
    await _debateRepository.rejectDebater(roomId, userId);
    await _debateRepository.sendApplicationNotification(
      roomId,
      userId,
      '😥 토론자 신청이 정중히 거절되었습니다.',
    );
  }

  // debate_room_controller.dart 에 추가할 것

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
    final auth = ref.read(firebaseAuthProvider); // ✅
    final user = auth.currentUser; // ✅
    if (user == null) return;

    await _debateRepository.applyDebater(
      roomId,
      user.uid, // ✅ 추가
      stance,
      message,
    );
  }

  // ✅ 관전자로 입장 메소드 추가
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
}
