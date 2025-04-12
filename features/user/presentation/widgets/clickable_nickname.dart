// lib/features/user/presentation/widgets/clickable_nickname.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/user_providers.dart';
import 'package:go_router/go_router.dart';

class ClickableNickname extends ConsumerWidget {
  final String uid;

  const ClickableNickname({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nicknameAsync = ref.watch(userNicknameProvider(uid));

    return nicknameAsync.when(
      data: (nickname) {
        return GestureDetector(
          onTap: () {
            context.push('/profile/$uid'); // ✅ uid로 이동
          },
          child: Text(
            nickname,
            style: const TextStyle(
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blueAccent,
              color: Colors.blueAccent,
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 50,
        height: 10,
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => const Text('닉네임 오류'),
    );
  }
}
