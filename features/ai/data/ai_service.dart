import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/error/app_exception.dart';

final String _openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

class AIService {
  AIService();

  /// 토론 기록을 기반으로 AI 평가 요청
  Future<String> evaluateDebate(List<Map<String, String>> debateLogs) async {
    if (_openAiApiKey.isEmpty) {
      throw AppException('OpenAI API 키가 설정되지 않았습니다.');
    }

    try {
      final messages = debateLogs.map((log) {
        return {
          'role': 'user',
          'content': '${log['user']}: ${log['message']}',
        };
      }).toList();

      final body = {
        'model': 'gpt-4', // 모델명은 상황에 따라
        'messages': [
          {
            'role': 'system',
            'content': '당신은 공정한 토론 심사관입니다. 발언을 평가하고 장단점과 점수를 매겨주세요.'
          },
          ...messages,
        ],
        'temperature': 0.7,
      };

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['choices'][0]['message']['content'];
        return aiReply;
      } else {
        throw AppException('AI 평가 실패: ${response.body}');
      }
    } catch (e) {
      throw AppException('AI 통신 오류: ${e.toString()}');
    }
  }
}
