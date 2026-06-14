import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../utils/recommender.dart';

class ChapterDetailScreen extends StatelessWidget {
  final Chapter chapter;
  final Recommender recommender;
  const ChapterDetailScreen({super.key, required this.chapter, required this.recommender});

  @override
  Widget build(BuildContext context) {
    final recoveryTime = recommender.calculateRecoveryTime(chapter);
    final sections = [
      _SectionData('Key Formulas', chapter.keyFormulas, Icons.functions),
      _SectionData('Detailed Notes', chapter.detailedNotes, Icons.notes),
      _SectionData('Examples', chapter.examples, Icons.lightbulb),
      _SectionData('Practice Problems', chapter.practiceProblems, Icons.assignment),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(chapter.name), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(chapter.name, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoChip(chapter.subject, Icons.book),
                      _infoChip('${chapter.pages} pages', Icons.auto_stories),
                      _infoChip('${chapter.weightage}% weightage', Icons.trending_up),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Estimated recovery: $recoveryTime min',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map((sec) => _SectionCard(data: sec)),
        ],
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
