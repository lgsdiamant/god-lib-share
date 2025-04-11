// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:god_of_debate/core/constants/constants.dart';
import 'package:god_of_debate/core/constants/constants_string.dart';
import 'package:god_of_debate/features/auth/application/auth_controller.dart';
import 'package:god_of_debate/features/home/presentation/widgets/agora_card.dart';
import 'package:god_of_debate/features/profile/application/profile_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(userProfileProvider.notifier).fetchMyProfile();
  }

  Future<void> _logout(BuildContext context) async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(homeTitle),
        actions: [
          profileAsync.when(
            data: (profile) {
              if (profile == null) {
                return const SizedBox();
              }
              return Row(
                children: [
                  Text(
                    profile['nickname'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: profile['photoUrl'] != null
                        ? NetworkImage(profile['photoUrl'])
                        : null,
                    child: profile['photoUrl'] == null
                        ? const Icon(Icons.person,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      context.push('/profile-view');
                    },
                    icon: const Icon(Icons.account_circle, color: Colors.white),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  AgoraCard(
                    title: '진지한 토론',
                    icon: Icons.forum,
                    route: '/debate-rooms',
                  ),
                  AgoraCard(
                    title: '새로운 관점',
                    icon: Icons.visibility,
                    route: '/new-perspectives',
                  ),
                  AgoraCard(
                    title: '지식과 정보',
                    icon: Icons.school,
                    route: '/knowledge',
                  ),
                  AgoraCard(
                    title: '소통과 존중',
                    icon: Icons.people_alt,
                    route: '/community',
                  ),
                  AgoraCard(
                    title: '나의 성장',
                    icon: Icons.bar_chart,
                    route: '/my-growth',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
