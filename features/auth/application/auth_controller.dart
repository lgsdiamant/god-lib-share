import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref.read(authRepositoryProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncData(null));

  /// 로그인
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signIn(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 회원가입
  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signUp(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      // 로그아웃은 실패해도 사용자에게 굳이 에러를 알릴 필요는 없음
    }
  }

  logout() {}
}
