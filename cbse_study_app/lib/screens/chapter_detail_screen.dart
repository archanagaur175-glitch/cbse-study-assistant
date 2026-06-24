import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/learner_model.dart';
import '../models/progress_entry.dart';
import '../services/recommendation_engine.dart';
import '../services/spaced_repetition.dart';
import '../services/ai_assistant.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Chapter chapter;
  final RecommendationEngine engine;
  final LearnerModel learner;
  final void Function(LearnerModel) onProgressUpdated;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
    required this.engine,
    required this.learner,
    required this.onProgressUpdated,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  late ProgressEntry _progress;
  String? _summary;
  String? _hint;
  String _selectedProblem = '';

  @override
  void initState() {
    super.initState();
    _progress = widget.learner.ensureProgress(widget.chapter.id);
  }

  void _markStudied({required bool understood, required double timeSeconds}) {
    final quality = SpacedRepetition.qualityFromPerformance(
      correct: understood,
      responseTimeSeconds: timeSeconds,
    );
    _progress.recordAttempt(correct: understood, responseTime: timeSeconds);
    SpacedRepetition.scheduleReview(entry: _progress, quality: quality);
    widget.learner.totalStudySessions++;
    widget.learner.totalMinutesStudied += (timeSeconds / 60).round().clamp(1, 60);
    widget.learner.lastActive = DateTime.now();

    setState(() {});
    widget.onProgressUpdated(widget.learner);
  }

  void _showReviewDialog() {
    final timeCtrl = TextEditingController(text: '15');
    String rating = 'understood';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How did it go?'),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'struggled', label: Text('Struggled')),
                ButtonSegment(value: 'understood', label: Text('Understood')),
                ButtonSegment(value: 'mastered', label: Text('Mastered')),
              ],
              selected: {rating},
              onSelectionChanged: (v) => rating = v.first,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                labelText: 'Time spent (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final minutes = double.tryParse(timeCtrl.text) ?? 15;
              _markStudied(
                understood: rating != 'struggled',
                timeSeconds: minutes * 60,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    if (_selectedProblem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap a practice problem first to get a hint')),
      );
      return;
    }
    setState(() {
      _hint = AiAssistant.generateHint(_selectedProblem, widget.chapter);
    });
  }

  void _showSummary() {
    setState(() {
      _summary = AiAssistant.summarizeNotes(widget.chapter.detailedNotes);
    });
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quick Summary'),
        content: Text(_summary ?? ''),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recoveryTime = widget.engine.calculateRecoveryTime(widget.chapter);
    final due = SpacedRepetition.isDue(_progress);
    final sections = [
      _SectionData('Key Formulas', widget.chapter.keyFormulas, Icons.functions),
      _SectionData('Detailed Notes', widget.chapter.detailedNotes, Icons.notes),
      _SectionData('Examples', widget.chapter.examples, Icons.lightbulb),
      _SectionData('Practice Problems', widget.chapter.practiceProblems, Icons.assignment),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.name), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(recoveryTime, due),
          const SizedBox(height: 12),
          _buildProgressCard(),
          const SizedBox(height: 12),
          _buildActionButtons(),
          const SizedBox(height: 12),
          if (_hint != null) _buildHintCard(),
          const SizedBox(height: 16),
          ...sections.map((sec) => _SectionCard(data: sec)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(int recoveryTime, bool due) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(widget.chapter.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoChip(widget.chapter.subject, Icons.book),
                _infoChip('${widget.chapter.pages} pages', Icons.auto_stories),
                _infoChip('${widget.chapter.weightage}% weightage', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: due
                    ? Colors.orange.shade100
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                due
                    ? 'Due for review! Estimated: $recoveryTime min'
                    : 'Estimated recovery: $recoveryTime min',
                style: TextStyle(
                  color: due ? Colors.orange.shade900 : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: due ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mastery', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${(_progress.masteryScore * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: _progress.masteryScore,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Attempts: ${_progress.accuracyHistory.length}',
                    style: const TextStyle(fontSize: 11)),
                Text('Retries: ${_progress.retryCount}',
                    style: const TextStyle(fontSize: 11)),
                Text('Avg time: ${_progress.averageResponseTime.round()}s',
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
            if (_progress.nextReviewDue != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next review: ${_progress.nextReviewDue!.day}/${_progress.nextReviewDue!.month} '
                '(in ${_progress.daysSinceLastReview}d)',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: _showReviewDialog,
          icon: const Icon(Icons.task_alt, size: 18),
          label: const Text('Mark Studied'),
        ),
        OutlinedButton.icon(
          onPressed: _showSummary,
          icon: const Icon(Icons.summarize, size: 18),
          label: const Text('Summary'),
        ),
        OutlinedButton.icon(
          onPressed: _showHint,
          icon: const Icon(Icons.lightbulb_outline, size: 18),
          label: const Text('Hint'),
        ),
      ],
    );
  }

  Widget _buildHintCard() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade800, size: 18),
                const SizedBox(width: 8),
                const Text('Hint', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(_hint ?? '', style: const TextStyle(fontSize: 13)),
            if (_selectedProblem.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('For: $_selectedProblem',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(data.icon),
        title: Text(data.title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.content, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
