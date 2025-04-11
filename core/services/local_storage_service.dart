import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';

  /// 이메일 저장
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  /// 비밀번호 저장
  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
  }

  /// 이메일 가져오기
  static Future<String?> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// 비밀번호 가져오기
  static Future<String?> loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  /// 저장된 이메일/비밀번호 삭제
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }
}
