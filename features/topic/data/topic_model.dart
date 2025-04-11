import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  final String id;
  final String title;
  final String description;
  final List<String> hashtags;
  final bool debateStarted;
  final DateTime? createdAt;

  TopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.hashtags,
    required this.debateStarted,
    required this.createdAt,
  });

  factory TopicModel.fromDocument(String id, Map<String, dynamic> data) {
    return TopicModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hashtags: List<String>.from(data['hashtags'] ?? []),
      debateStarted: data['debateStarted'] ?? false,
      createdAt: (data['createdAt'] != null)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'hashtags': hashtags,
      'debateStarted': debateStarted,
      'createdAt': createdAt,
    };
  }
}
