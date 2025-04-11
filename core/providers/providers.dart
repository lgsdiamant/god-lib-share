import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:god_of_debate/features/topic/application/topic_controller.dart';
import 'package:god_of_debate/features/topic/data/topic_repository.dart';
import 'package:god_of_debate/features/topic/data/topic_model.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/ai/data/ai_service.dart';

// 인증 관련
final authRepositoryProvider = Provider((ref) => AuthRepository());
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref.read(authRepositoryProvider)),
);

// 토론 주제 관련
final topicRepositoryProvider = Provider((ref) => TopicRepository());
final topicControllerProvider =
    StateNotifierProvider<TopicController, AsyncValue<List<TopicModel>>>(
  (ref) => TopicController(),
);

// AI 관련 (기본 OpenAI 선택)
final aiServiceProvider = Provider<AIService>((ref) => AIService());
