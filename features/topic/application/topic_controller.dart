import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/topic_model.dart';
import '../../../core/error/app_exception.dart';

final topicControllerProvider =
    StateNotifierProvider<TopicController, AsyncValue<List<TopicModel>>>(
  (ref) => TopicController(),
);

class TopicController extends StateNotifier<AsyncValue<List<TopicModel>>> {
  TopicController() : super(const AsyncLoading()) {
    fetchTopics();
  }

  /// Firestore에서 토론 주제 가져오기
  Future<void> fetchTopics() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .orderBy('createdAt', descending: true)
          .get();

      final topics = querySnapshot.docs.map((doc) {
        return TopicModel.fromDocument(
          doc.id,
          doc.data(),
        );
      }).toList();

      state = AsyncData(topics);
    } catch (e) {
      state = AsyncError(
        AppException('토픽 로딩 실패: ${e.toString()}'),
        StackTrace.current,
      );
    }
  }

  /// 검색어로 토론 주제 필터링
  void searchTopics(String query) async {
    try {
      final allTopics = await FirebaseFirestore.instance
          .collection('topics')
          .orderBy('createdAt', descending: true)
          .get();

      final topics = allTopics.docs.map((doc) {
        return TopicModel.fromDocument(
          doc.id,
          doc.data(),
        );
      }).where((topic) {
        return topic.title.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
            topic.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
            topic.hashtags.any(
              (tag) => tag.contains(query.toLowerCase()),
            );
      }).toList();

      state = AsyncData(topics);
    } catch (e) {
      state = AsyncError(
        AppException('검색 실패: ${e.toString()}'),
        StackTrace.current,
      );
    }
  }

  /// 새로운 토론 주제 추가
  Future<void> addTopic(TopicModel topic) async {
    try {
      await FirebaseFirestore.instance.collection('topics').add(topic.toMap());
      await fetchTopics(); // 추가 후 리스트 새로고침
    } catch (e) {
      throw AppException('토픽 추가 실패: ${e.toString()}');
    }
  }
}
