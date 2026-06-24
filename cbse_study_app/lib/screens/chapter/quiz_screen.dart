import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../data/chapters.dart';
import '../../services/ai_service.dart';

class QuizScreen extends StatefulWidget {
  final int chapterId;
  const QuizScreen({super.key, required this.chapterId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<AiGeneratedQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showResult = false;
  int _correctCount = 0;
  bool _finished = false;
  final Stopwatch _questionTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final chapter = allChapters.firstWhere((c) => c.id == widget.chapterId);
    _questions = AIService.generateQuestions(chapter, count: 5);
    if (_questions.isNotEmpty) _questionTimer.start();
  }

  void _submitAnswer() {
    if (_selectedIndex == null) return;
    _questionTimer.stop();
    final correct = _selectedIndex == _questions[_currentIndex].correctIndex;
    if (correct) _correctCount++;
    final state = context.read<AppState>();
    state.recordQuizAttempt(
      chapterId: widget.chapterId,
      correct: correct,
      responseTimeSeconds: _questionTimer.elapsedMilliseconds / 1000.0,
    );
    setState(() => _showResult = true);
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showResult = false;
      _questionTimer.reset();
      _questionTimer.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    if (_finished) {
      final total = _questions.length;
      final pct = _correctCount / total;
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Complete')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  pct >= 0.7 ? Icons.celebration : Icons.autorenew,
                  size: 64,
                  color: pct >= 0.7 ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text('$_correctCount / $total correct',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${(pct * 100).round()}% accuracy',
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text(
                  pct >= 0.7
                      ? 'Great job! Mastery improving.'
                      : 'Keep practicing! You\'ll improve.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Chapter')),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final isCorrect = _showResult && _selectedIndex == q.correctIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz (${_currentIndex + 1}/${_questions.length})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(q.question,
                    style: const TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(q.options.length, (i) {
              Color? bg;
              if (_showResult) {
                if (i == q.correctIndex) {
                  bg = Colors.green.withOpacity(0.2);
                } else if (i == _selectedIndex && i != q.correctIndex) {
                  bg = Colors.red.withOpacity(0.2);
                }
              } else if (i == _selectedIndex) {
                bg = Theme.of(context).colorScheme.primaryContainer;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showResult
                        ? null
                        : () => setState(() => _selectedIndex = i),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            _showResult
                                ? (i == q.correctIndex
                                    ? Icons.check_circle
                                    : i == _selectedIndex
                                        ? Icons.cancel
                                        : Icons.radio_button_unchecked)
                                : (i == _selectedIndex
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked),
                            size: 20,
                            color: _showResult
                                ? (i == q.correctIndex
                                    ? Colors.green
                                    : i == _selectedIndex
                                        ? Colors.red
                                        : Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(q.options[i],
                                  style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (_showResult && q.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.05)
                      : Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.info,
                      size: 18,
                      color: isCorrect ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(q.explanation,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _showResult ? _nextQuestion : _submitAnswer,
                child: Text(_showResult ? 'Next' : 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
