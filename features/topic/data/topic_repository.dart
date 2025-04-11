import 'package:cloud_firestore/cloud_firestore.dart';
import 'topic_model.dart';
import '../../../core/error/app_exception.dart';

class TopicRepository {
  final FirebaseFirestore _firestore;

  TopicRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 모든 토론 주제 가져오기
  Future<List<TopicModel>> fetchTopics() async {
    try {
      final querySnapshot = await _firestore
          .collection('topics')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return TopicModel.fromDocument(
          doc.id,
          doc.data(),
        );
      }).toList();
    } catch (e) {
      throw AppException('토픽 가져오기 실패: ${e.toString()}');
    }
  }

  /// 검색어로 토론 주제 필터링
  Future<List<TopicModel>> searchTopics(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('topics')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return TopicModel.fromDocument(
          doc.id,
          doc.data(),
        );
      }).where((topic) {
        return topic.title.toLowerCase().contains(query.toLowerCase()) ||
            topic.description.toLowerCase().contains(query.toLowerCase()) ||
            topic.hashtags.any((tag) => tag.contains(query.toLowerCase()));
      }).toList();
    } catch (e) {
      throw AppException('토픽 검색 실패: ${e.toString()}');
    }
  }

  /// 새 토론 주제 추가
  Future<void> addTopic(TopicModel topic) async {
    try {
      await _firestore.collection('topics').add(topic.toMap());
    } catch (e) {
      throw AppException('토픽 추가 실패: ${e.toString()}');
    }
  }
}
