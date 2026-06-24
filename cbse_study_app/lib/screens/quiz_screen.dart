import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/learner_model.dart';
import '../services/ai_service.dart';
import '../services/progress_tracker.dart';

class QuizScreen extends StatefulWidget {
  final Chapter chapter;
  final ProgressTracker tracker;

  const QuizScreen({super.key, required this.chapter, required this.tracker});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<AiGeneratedQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _correctCount = 0;
  int _totalAnswered = 0;
  final _stopwatch = Stopwatch();
  final List<bool> _results = [];

  @override
  void initState() {
    super.initState();
    _questions = AIService.generateQuestions(widget.chapter, count: 5);
    _stopwatch.start();
  }

  void _answer(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      _totalAnswered++;
      final correct = index == _questions[_currentIndex].correctIndex;
      if (correct) _correctCount++;
      _results.add(correct);
    });
    final elapsed = _stopwatch.elapsedMilliseconds / 1000.0;
    widget.tracker.recordQuizAttempt(
      chapterId: widget.chapter.id,
      correct: index == _questions[_currentIndex].correctIndex,
      responseTimeSeconds: elapsed,
    );
    _stopwatch.reset();
    _stopwatch.start();
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      _stopwatch.stop();
      _showResults();
    }
  }

  void _showResults() {
    final masteryBefore = widget.tracker.getProgress(widget.chapter.id).masteryScore;
    final masteryAfter = widget.tracker.getProgress(widget.chapter.id).masteryScore;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '$_correctCount/${_totalAnswered}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _correctCount >= _totalAnswered / 2
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _correctCount >= _totalAnswered / 2
                    ? 'Great job! Keep practicing.'
                    : 'Review the chapter and try again.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _totalAnswered > 0 ? _correctCount / _totalAnswered : 0,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text('Mastery: ${(masteryBefore * 100).round()}% → ${(masteryAfter * 100).round()}%'),
            Text('Next review: ${widget.tracker.getProgress(widget.chapter.id).nextReviewDue?.day}/${widget.tracker.getProgress(widget.chapter.id).nextReviewDue?.month ?? '?'}'),
            const SizedBox(height: 12),
            ..._results.asMap().entries.map((e) => Row(
              children: [
                Icon(e.value ? Icons.check_circle : Icons.cancel,
                    color: e.value ? Colors.green : Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Q${e.key + 1}', style: const TextStyle(fontSize: 13))),
              ],
            )),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz: ${widget.chapter.name}')),
        body: const Center(child: Text('Could not generate questions for this chapter.')),
      );
    }

    final q = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.chapter.name}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_currentIndex + 1}/${_questions.length}',
                    style: Theme.of(context).textTheme.bodySmall),
                Text('$_correctCount/$_totalAnswered correct',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(q.question, style: const TextStyle(fontSize: 16, height: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(q.options.length, (i) {
              final isSelected = _selectedIndex == i;
              final isCorrect = i == q.correctIndex;
              Color? bg;
              Color? fg;
              if (_answered) {
                if (isCorrect) {
                  bg = Colors.green.shade50;
                  fg = Colors.green.shade800;
                } else if (isSelected && !isCorrect) {
                  bg = Colors.red.shade50;
                  fg = Colors.red.shade800;
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _answered ? null : () => _answer(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _answered && isCorrect
                                ? Icons.check_circle
                                : _answered && isSelected && !isCorrect
                                    ? Icons.cancel
                                    : Icons.radio_button_unchecked,
                            color: fg ?? Colors.grey.shade600,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: TextStyle(
                                fontSize: 14,
                                color: fg ?? Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (_answered) ...[
              const SizedBox(height: 8),
              Card(
                color: _selectedIndex == q.correctIndex
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _selectedIndex == q.correctIndex
                            ? Icons.emoji_events
                            : Icons.lightbulb_outline,
                        color: _selectedIndex == q.correctIndex
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedIndex == q.correctIndex
                              ? 'Correct! ${q.explanation}'
                              : q.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedIndex == q.correctIndex
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: _next,
                  icon: Icon(_currentIndex < _questions.length - 1
                      ? Icons.arrow_forward
                      : Icons.check),
                  label: Text(_currentIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'See Results'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
