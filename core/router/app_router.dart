import 'package:go_router/go_router.dart';
import 'package:god_of_debate/features/admin/presentation/admin_notice_screen.dart';
import 'package:god_of_debate/features/admin/presentation/admin_topic_screen.dart';
import 'package:god_of_debate/features/admin/presentation/admin_user_screen.dart';
import 'package:god_of_debate/features/auth/presentation/login_screen.dart';
import 'package:god_of_debate/features/auth/presentation/signup_screen.dart';
import 'package:god_of_debate/features/debate/presentation/create_debate_room_screen.dart';
import 'package:god_of_debate/features/debate/presentation/waiting_debate_rooms_screen.dart';
import 'package:god_of_debate/features/home/presentation/home_screen.dart';
import 'package:god_of_debate/features/profile/presentation/profile_edit_screen.dart';
import 'package:god_of_debate/features/profile/presentation/profile_view_screen.dart';
import 'package:god_of_debate/features/topic/presentation/create_topic_screen.dart';
import 'package:god_of_debate/features/debate/presentation/debate_room_screen.dart';
import 'package:god_of_debate/features/ai/presentation/ai_result_screen.dart';
import 'package:god_of_debate/features/admin/presentation/admin_screen.dart';
import 'package:god_of_debate/features/splash/presentation/splash_screen.dart';
import 'package:god_of_debate/features/topic/presentation/topic_template_search_screen.dart';
import 'package:god_of_debate/features/debate/presentation/create_debate_room_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile-view',
      builder: (context, state) => const ProfileViewScreen(),
    ),
    GoRoute(
      path: '/profile-edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/create-topic',
      builder: (context, state) => const CreateTopicScreen(),
    ),
    GoRoute(
      path: '/debate-room/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DebateRoomScreen(roomId: id);
      },
    ),
    GoRoute(
      path: '/ai-result',
      builder: (context, state) => const AIResultScreen(
        debateLogs: [],
        apiKey: '', // 실제 호출 시 전달
      ),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),

    // debate
    GoRoute(
      path: '/debate-rooms',
      builder: (context, state) => const WaitingDebateRoomsScreen(), // 이걸 추가!
    ),

    /// Admin
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const AdminUserScreen(), // (곧 드릴거야)
    ),
    GoRoute(
      path: '/admin/topics',
      builder: (context, state) => const AdminTopicScreen(), // (곧 드릴거야)
    ),
    GoRoute(
      path: '/admin/notices',
      builder: (context, state) => const AdminNoticeScreen(), // (곧 드릴거야)
    ),

    GoRoute(
      path: '/create-debate-room',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final topicTitle = extra?['title'] ?? '';
        final topicDescription = extra?['description'] ?? '';
        final stances = List<String>.from(extra?['stances'] ?? []);

        return CreateDebateRoomScreen(
          topicTitle: topicTitle,
          topicDescription: topicDescription,
          stances: stances,
        );
      },
    ),

    GoRoute(
      path: '/topic-template-search',
      builder: (context, state) => const TopicTemplateSearchScreen(),
    ),
  ],
);
