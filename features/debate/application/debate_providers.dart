import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 대기 중 토론방 Provider
final waitingDebateRoomsProvider =
    StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final query = FirebaseFirestore.instance
      .collection('debate_rooms')
      .where('status', isEqualTo: 'waiting')
      .where('isPrivate', isEqualTo: false)
      .orderBy('createdAt', descending: true);
  return query.snapshots().map((snapshot) => snapshot.docs);
});

// 진행 중 토론방 Provider
final activeDebateRoomsProvider =
    StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final query = FirebaseFirestore.instance
      .collection('debate_rooms')
      .where('status', isEqualTo: 'active')
      .where('isPrivate', isEqualTo: false)
      .orderBy('createdAt', descending: true);
  return query.snapshots().map((snapshot) => snapshot.docs);
});

// 종료된 토론방 Provider
final closedDebateRoomsProvider =
    StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final query = FirebaseFirestore.instance
      .collection('debate_rooms')
      .where('status', isEqualTo: 'closed')
      .where('isPrivate', isEqualTo: false)
      .orderBy('createdAt', descending: true);
  return query.snapshots().map((snapshot) => snapshot.docs);
});

// 개별 토론방 정보 Provider
final debateRoomProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, roomId) {
  final doc = FirebaseFirestore.instance.collection('debate_rooms').doc(roomId);
  return doc.snapshots().map((snapshot) => snapshot.data() ?? {});
});

// 개별 토론방 메시지 Provider
final debateMessagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, roomId) {
  final collection = FirebaseFirestore.instance
      .collection('debate_rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('createdAt', descending: false);
  return collection.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
});

// 개별 토론방 투표 Provider
final debateVotesProvider =
    StreamProvider.family<Map<String, int>, String>((ref, roomId) {
  final doc = FirebaseFirestore.instance
      .collection('debate_rooms')
      .doc(roomId)
      .collection('votes')
      .doc('voteResult');
  return doc.snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data == null) return {};
    return data.map((key, value) => MapEntry(key, value as int));
  });
});
