import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_dialog.dart';
import '../data/ai_service.dart'; // AI 서비스 import 필요

class AIResultScreen extends ConsumerStatefulWidget {
  final List<Map<String, String>> debateLogs; // 토론 기록
  final String apiKey; // OpenAI API Key

  const AIResultScreen({
    super.key,
    required this.debateLogs,
    required this.apiKey,
  });

  @override
  ConsumerState<AIResultScreen> createState() => _AIResultScreenState();
}

class _AIResultScreenState extends ConsumerState<AIResultScreen> {
  String? _evaluationResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getEvaluation();
  }

  Future<void> _getEvaluation() async {
    setState(() => _isLoading = true);

    try {
      final aiService = AIService();
      final result = await aiService.evaluateDebate(widget.debateLogs);

      setState(() {
        _evaluationResult = result;
      });
    } catch (e) {
      showErrorDialog(context, 'AI 평가 실패: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 평가 결과')),
      body: _isLoading
          ? const LoadingIndicator()
          : _evaluationResult == null
              ? const Center(child: Text('결과를 가져오지 못했습니다.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(
                      _evaluationResult!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
      bottomNavigationBar: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _goHome(context),
                child: const Text('홈으로 돌아가기'),
              ),
            ),
    );
  }
}
