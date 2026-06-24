import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../data/chapters.dart';
import '../../models/chapter.dart';
import '../../services/ai_service.dart';
import '../../widgets/action_button_row.dart';
import '../chapter/quiz_screen.dart';

class ChapterDetailScreen extends StatelessWidget {
  final int chapterId;
  const ChapterDetailScreen({super.key, required this.chapterId});

  Chapter get chapter => allChapters.firstWhere((c) => c.id == chapterId);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ch = chapter;
    final progress = state.getProgress(ch.id);
    final timerStr = '${(state.elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(state.elapsedSeconds % 60).toString().padLeft(2, '0')}';

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) state.stopChapterTimer();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ch.name, style: const TextStyle(fontSize: 16)),
              Text(ch.subject,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(timerStr,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildMasteryIndicator(progress.masteryScore),
            const SizedBox(height: 8),
            ActionButtonRow(items: [
              ActionButtonItem(
                label: 'Mark Studied',
                icon: Icons.check_circle_outline,
                color: Colors.green,
                onTap: () => _markStudied(context, state, ch),
              ),
              ActionButtonItem(
                label: 'Quiz',
                icon: Icons.quiz_outlined,
                color: Colors.blue,
                onTap: () => _startQuiz(context, state, ch),
              ),
              ActionButtonItem(
                label: 'Summary',
                icon: Icons.summarize_outlined,
                color: Colors.purple,
                onTap: () => _showSummary(context, ch),
              ),
              ActionButtonItem(
                label: 'AI Q&A',
                icon: Icons.smart_toy_outlined,
                color: Colors.teal,
                onTap: () => _showAiQa(context, ch),
              ),
            ]),
            const SizedBox(height: 12),
            _buildSection('Key Formulas', ch.keyFormulas.split('\n')),
            _buildSection('Detailed Notes', ch.detailedNotes.split('\n')),
            _buildSection('Examples', ch.examples.split('\n')),
            _buildSection('Practice Problems', ch.practiceProblems.split('\n')),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryIndicator(double mastery) {
    final color = mastery >= 0.7
        ? Colors.green
        : mastery >= 0.4
            ? Colors.orange
            : Colors.grey;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: mastery,
              minHeight: 6,
              color: color,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(mastery * 100).round()}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 13)),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _markStudied(BuildContext context, AppState state, Chapter ch) {
    state.markStudied(chapterId: ch.id, understood: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress saved!'), duration: Duration(seconds: 1)),
    );
  }

  void _startQuiz(BuildContext context, AppState state, Chapter ch) {
    state.pauseTimer();
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: state,
        child: QuizScreen(chapterId: ch.id),
      ),
    ))
        .then((_) => state.resumeTimer());
  }

  void _showSummary(BuildContext context, Chapter ch) {
    final summary = AIService.summarizeChapter(ch);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chapter Summary',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (summary.keyPoints.isNotEmpty) ...[
              const Text('Key Points',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(summary.keyPoints, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
            ],
            if (summary.keyFormulas.isNotEmpty) ...[
              const Text('Formulas',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(summary.keyFormulas, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
            ],
            if (summary.keyTerms.isNotEmpty) ...[
              const Text('Key Terms',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(summary.keyTerms, style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAiQa(BuildContext context, Chapter ch) {
    final hint = AIService.generateQuickExplanation('key concepts', ch);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI Study Assistant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('I can help you understand this chapter.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            const Text('Quick explanation:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(hint, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text('Try taking a quiz or reviewing the key formulas!',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
