import 'package:flutter/material.dart';
import '../../../topic/data/topic_model.dart';
import 'package:go_router/go_router.dart';

class TopicList extends StatelessWidget {
  final List<TopicModel> topics;

  const TopicList({super.key, required this.topics});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const Center(child: Text('등록된 토론 주제가 없습니다.'));
    }

    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return ListTile(
          title: Text(
            topic.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            topic.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            context.push('/debate-room/${topic.id}');
          },
        );
      },
    );
  }
}
