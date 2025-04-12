import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../debate/presentation/create_debate_room_screen.dart';

class TopicTemplateSearchScreen extends StatefulWidget {
  const TopicTemplateSearchScreen({super.key});

  @override
  State<TopicTemplateSearchScreen> createState() =>
      _TopicTemplateSearchScreenState();
}

class _TopicTemplateSearchScreenState extends State<TopicTemplateSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<QuerySnapshot> _fetchApprovedTopics() async* {
    try {
      yield* FirebaseFirestore.instance
          .collection('topics')
          .where('approved', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e, stackTrace) {
      yield* Stream.error(e, stackTrace);
    }
  }

  void _selectTopic(DocumentSnapshot topic) {
    final topicTitle = topic['title'] ?? '';
    final topicDescription = topic['description'] ?? '';

    context.push('/create-debate-room', extra: {
      'title': topicTitle,
      'description': topicDescription,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주제 템플릿 선택'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: '주제 검색',
                hintText: '주제 제목 또는 설명 입력',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchApprovedTopics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('오류 발생: ${snapshot.error}'));
                  }

                  final topics = snapshot.data?.docs ?? [];

                  final filteredTopics = topics.where((doc) {
                    final title = (doc['title'] ?? '').toString();
                    final description = (doc['description'] ?? '').toString();
                    return title.contains(_searchQuery) ||
                        description.contains(_searchQuery);
                  }).toList();

                  if (filteredTopics.isEmpty) {
                    return const Center(
                      child: Text('조건에 맞는 주제가 없습니다.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
                      return Card(
                        child: ListTile(
                          title: Text(topic['title'] ?? '제목 없음'),
                          subtitle: Text(topic['description'] ?? '설명 없음'),
                          onTap: () => _selectTopic(topic),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
