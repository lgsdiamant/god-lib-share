import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error/app_exception.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 로그인된 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// 이메일/비밀번호 로그인
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (!_auth.currentUser!.emailVerified) {
        throw AppException('이메일 인증을 완료해야 합니다.');
      }
    } on FirebaseAuthException catch (e) {
      throw AppException(_handleAuthError(e));
    }
  }

  /// 회원가입 + 이메일 인증 발송
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AppException(_handleAuthError(e));
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 이메일 인증 다시 보내기
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw AppException('인증 이메일을 다시 보내지 못했습니다.');
    }
  }

  /// 에러 메시지 핸들링
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return '유효하지 않은 이메일입니다.';
      case 'user-disabled':
        return '이 계정은 비활성화되었습니다.';
      case 'user-not-found':
        return '존재하지 않는 계정입니다.';
      case 'wrong-password':
        return '비밀번호가 틀렸습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      default:
        return '알 수 없는 오류: ${e.message}';
    }
  }
}
