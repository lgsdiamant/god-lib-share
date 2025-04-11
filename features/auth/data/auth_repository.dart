import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error/app_exception.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  /// 로그인
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!_auth.currentUser!.emailVerified) {
        throw AppException('이메일 인증을 완료하세요.');
      }
    } on FirebaseAuthException catch (e) {
      throw AppException(_handleError(e));
    }
  }

  /// 회원가입
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AppException(_handleError(e));
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 에러 핸들러
  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return '올바르지 않은 이메일 형식입니다.';
      case 'user-not-found':
        return '존재하지 않는 사용자입니다.';
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
