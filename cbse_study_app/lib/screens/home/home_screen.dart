import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../data/chapters.dart';
import '../../models/progress_entry.dart';
import '../../widgets/mastery_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/subject_grid.dart';
import '../../widgets/horizontal_card.dart';
import '../chapter/chapter_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final due = state.dueReviews;
    final weak = state.weakestTopics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBSE Study Assistant'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => false,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const MasteryBanner(),
            if (due.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionHeader(
                  title: 'Due for Review',
                  count: due.length,
                  color: Colors.orange),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: due.map((e) {
                    final ch = allChapters.firstWhere((c) => c.id == e.chapterId);
                    return HorizontalCard(
                      title: ch.subject,
                      subtitle: ch.name,
                      color: Colors.orange,
                      onTap: () => _openChapter(context, ch.id),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (weak.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionHeader(
                  title: 'Weak Topics', count: weak.length, color: Colors.red),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: weak.map((e) {
                    final ch = allChapters.firstWhere((c) => c.id == e.chapterId);
                    return HorizontalCard(
                      title: ch.name,
                      subtitle: '${(e.masteryScore * 100).round()}% mastered',
                      color: Colors.red,
                      onTap: () => _openChapter(context, ch.id),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SectionHeader(
                title: 'Subjects',
                count: allChapters.length,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            SubjectGrid(
              onSubjectTap: (subject) => _filterBySubject(context, subject),
            ),
          ],
        ),
      ),
    );
  }

  void _openChapter(BuildContext context, int chapterId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppState>(),
        child: ChapterDetailScreen(chapterId: chapterId),
      ),
    ));
  }

  void _filterBySubject(BuildContext context, String subject) {
    final tabState = context.read<AppState>();
    tabState.setTab(1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing $subject chapters in Search'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
