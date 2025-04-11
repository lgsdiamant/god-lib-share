import 'package:cloud_firestore/cloud_firestore.dart';
import '../error/app_exception.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자 프로필 저장
  Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(profileData, SetOptions(merge: true));
    } catch (e) {
      throw AppException('프로필 저장 실패: ${e.toString()}');
    }
  }

  /// 사용자 프로필 가져오기
  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw AppException('프로필 조회 실패: ${e.toString()}');
    }
  }

  /// 새 토론 주제 생성
  Future<void> createTopic(Map<String, dynamic> topicData) async {
    try {
      await _firestore.collection('topics').add(topicData);
    } catch (e) {
      throw AppException('토론 주제 생성 실패: ${e.toString()}');
    }
  }

  /// 채팅 메시지 추가
  Future<void> sendMessage({
    required String topicId,
    required Map<String, dynamic> messageData,
  }) async {
    try {
      await _firestore
          .collection('topics')
          .doc(topicId)
          .collection('chats')
          .add(messageData);
    } catch (e) {
      throw AppException('메시지 전송 실패: ${e.toString()}');
    }
  }

  /// 관전자 댓글 추가
  Future<void> sendObserverComment({
    required String topicId,
    required Map<String, dynamic> commentData,
  }) async {
    try {
      await _firestore
          .collection('topics')
          .doc(topicId)
          .collection('observers')
          .add(commentData);
    } catch (e) {
      throw AppException('관전자 댓글 전송 실패: ${e.toString()}');
    }
  }

  /// 토론 상태 업데이트 (시작/종료)
  Future<void> updateDebateState({
    required String topicId,
    required bool started,
  }) async {
    try {
      await _firestore.collection('topics').doc(topicId).update({
        'debateStarted': started,
      });
    } catch (e) {
      throw AppException('토론 상태 변경 실패: ${e.toString()}');
    }
  }
}
