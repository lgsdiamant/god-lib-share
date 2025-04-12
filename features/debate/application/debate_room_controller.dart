import 'package:cloud_firestore/cloud_firestore.dart';
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
    await docRef.update({
      'observers': FieldValue.arrayUnion([user.uid]),
    });
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
}
