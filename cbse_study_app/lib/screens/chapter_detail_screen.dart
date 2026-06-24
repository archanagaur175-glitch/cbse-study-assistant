import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/learner_model.dart';
import '../models/progress_entry.dart';
import '../services/recommendation_engine.dart';
import '../services/spaced_repetition.dart';
import '../services/ai_service.dart';
import '../services/progress_tracker.dart';
import 'quiz_screen.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Chapter chapter;
  final RecommendationEngine engine;
  final ProgressTracker tracker;
  final void Function(LearnerModel) onProgressUpdated;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
    required this.engine,
    required this.tracker,
    required this.onProgressUpdated,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  late ProgressEntry _progress;
  ProgressTracker get _tracker => widget.tracker;

  @override
  void initState() {
    super.initState();
    _progress = _tracker.getProgress(widget.chapter.id);
    _tracker.startTracking(widget.chapter.id);
  }

  @override
  void dispose() {
    _tracker.stopTracking();
    super.dispose();
  }

  void _markStudied({required bool understood}) {
    final timeSeconds = _tracker.elapsedSeconds.toDouble().clamp(1.0, 3600.0);
    final quality = SpacedRepetition.qualityFromPerformance(
      correct: understood,
      responseTimeSeconds: timeSeconds,
    );
    _progress.recordAttempt(correct: understood, responseTime: timeSeconds);
    SpacedRepetition.scheduleReview(entry: _progress, quality: quality);
    _tracker.learner.totalStudySessions++;
    _tracker.learner.lastActive = DateTime.now();

    setState(() {});
    widget.onProgressUpdated(_tracker.learner);
  }

  void _showUnderstandingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Did you understand this topic?'),
        content: const Text('This helps us adjust your review schedule.'),
        actions: [
          OutlinedButton(
            onPressed: () {
              _markStudied(understood: false);
              Navigator.pop(ctx);
            },
            child: const Text('Not really'),
          ),
          FilledButton(
            onPressed: () {
              _markStudied(understood: true);
              Navigator.pop(ctx);
            },
            child: const Text('Yes, understood'),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog() {
    final summary = AIService.summarizeChapter(widget.chapter);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber.shade700, size: 22),
            const SizedBox(width: 8),
            const Text('AI Summary'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Key Points', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(summary.keyPoints, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              const Text('Key Formulas', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(summary.keyFormulas, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              const Text('Key Terms', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(summary.keyTerms, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(chapter: widget.chapter, tracker: _tracker),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recoveryTime = widget.engine.calculateRecoveryTime(widget.chapter);
    final due = SpacedRepetition.isDue(_progress);
    final timerSeconds = _tracker.elapsedSeconds;
    final timerDisplay = '${timerSeconds ~/ 60}:${(timerSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.name),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(timerDisplay, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: [
          _buildHeaderCard(recoveryTime, due),
          const SizedBox(height: 10),
          _buildMasteryCard(),
          const SizedBox(height: 10),
          _buildActionRow(context),
          const SizedBox(height: 16),
          _buildContentSections(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(int recoveryTime, bool due) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(widget.chapter.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _chip(widget.chapter.subject, Icons.book, null),
                _chip('${widget.chapter.pages} pages', Icons.auto_stories, null),
                _chip('${widget.chapter.weightage}%', Icons.trending_up, null),
                _chip('$recoveryTime min', Icons.timer_outlined, due ? Colors.orange : null),
              ],
            ),
            if (due) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_active, size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text('Due for review!',
                        style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color? highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlight?.withOpacity(0.1) ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: highlight ?? Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: highlight ?? Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildMasteryCard() {
    final nextReview = _progress.nextReviewDue;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Mastery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text('${(_progress.masteryScore * 100).round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _progress.masteryScore >= 0.7
                          ? Colors.green
                          : _progress.masteryScore >= 0.4
                              ? Colors.orange
                              : Colors.red,
                    )),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress.masteryScore,
                minHeight: 8,
                color: _progress.masteryScore >= 0.7
                    ? Colors.green
                    : _progress.masteryScore >= 0.4
                        ? Colors.orange
                        : Colors.red,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Attempts: ${_progress.accuracyHistory.length}', style: const TextStyle(fontSize: 11)),
                Text('Retries: ${_progress.retryCount}', style: const TextStyle(fontSize: 11)),
                Text('${_tracker.elapsedSeconds}s', style: const TextStyle(fontSize: 11)),
              ],
            ),
            if (nextReview != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next review: ${nextReview.day}/${nextReview.month} '
                '(interval: ${_progress.interval}d)',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _actionButton(
            label: 'Mark Studied',
            icon: Icons.task_alt,
            color: Colors.green,
            onTap: _showUnderstandingDialog,
          ),
          _actionButton(
            label: 'Take Quiz',
            icon: Icons.quiz,
            color: Colors.blue,
            onTap: _openQuiz,
          ),
          _actionButton(
            label: 'AI Summary',
            icon: Icons.auto_awesome,
            color: Colors.amber.shade700,
            onTap: _showSummaryDialog,
          ),
          _actionButton(
            label: 'Generate Q&A',
            icon: Icons.psychology,
            color: Colors.purple,
            onTap: () {
              final questions = AIService.generateQuestions(widget.chapter, count: 2);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple.shade400, size: 22),
                      const SizedBox(width: 8),
                      const Text('AI Generated Questions'),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: questions.asMap().entries.map((e) {
                        final q = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Q${e.key + 1}: ${q.question}',
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                              const SizedBox(height: 4),
                              ...q.options.asMap().entries.map((opt) => Text(
                                '  ${opt.key == q.correctIndex ? "✓" : "○"} ${opt.value}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: opt.key == q.correctIndex ? Colors.green.shade700 : null,
                                  fontWeight: opt.key == q.correctIndex ? FontWeight.w600 : null,
                                ),
                              )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSections() {
    final sections = [
      _SectionData('Key Formulas', widget.chapter.keyFormulas, Icons.functions),
      _SectionData('Detailed Notes', widget.chapter.detailedNotes, Icons.notes),
      _SectionData('Examples', widget.chapter.examples, Icons.lightbulb),
      _SectionData('Practice Problems', widget.chapter.practiceProblems, Icons.assignment),
    ];
    return Column(
      children: sections.map((sec) => _SectionCard(data: sec)).toList(),
    );
  }
}

class _SectionData {
  final String title;
  final String content;
  final IconData icon;
  _SectionData(this.title, this.content, this.icon);
}

class _SectionCard extends StatelessWidget {
  final _SectionData data;
  const _SectionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(data.icon),
        title: Text(data.title, style: const TextStyle(fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.content, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
