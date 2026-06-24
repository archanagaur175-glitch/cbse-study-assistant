import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/profile.dart';
import '../models/learner_model.dart';
import '../data/chapters.dart';
import '../services/recommendation_engine.dart';
import '../services/progress_tracker.dart';
import '../storage/user_progress.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chapter_detail_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  final Profile profile;
  final LearnerModel learner;
  const HomeScreen({super.key, required this.profile, required this.learner});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RecommendationEngine _engine;
  late ProgressTracker _tracker;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tracker = ProgressTracker(
      learner: widget.learner,
      onSave: (updated) => UserProgressStore.save(updated),
    );
    _engine = RecommendationEngine(
      chapters: allChapters,
      profile: widget.profile,
      learner: _tracker.learner,
    );
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  Future<void> _saveLearner() async {
    await UserProgressStore.save(_tracker.learner);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      SearchScreen(
        engine: _engine,
        tracker: _tracker,
        onProgressUpdated: _onProgressUpdated,
      ),
      ProfileScreen(profile: widget.profile, learner: _tracker.learner),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final recommendations = _engine.getTopRecommendations(count: 4);
    final dueReviews = _tracker.learner.dueReviews;
    final weakTopics = _tracker.learner.weakestTopics;

    return Scaffold(
      appBar: AppBar(title: Text('Hi, ${widget.profile.name}'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          _buildMasteryBanner(),
          const SizedBox(height: 10),
          if (dueReviews.isNotEmpty) _buildSection('Due for Review', dueReviews.length, Colors.orange, () {}),
          if (dueReviews.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDueCards(dueReviews),
          ],
          const SizedBox(height: 12),
          _buildSection('Recommended for You', recommendations.length, Colors.blue, _openQuickQuiz),
          const SizedBox(height: 8),
          _buildRecommendationCards(recommendations),
          const SizedBox(height: 12),
          if (weakTopics.isNotEmpty) ...[
            _buildSection('Needs Attention', weakTopics.length, Colors.red, () {}),
            const SizedBox(height: 8),
            _buildWeakCards(weakTopics),
            const SizedBox(height: 12),
          ],
          _buildSection('All Chapters', allChapters.length, Colors.grey, () {}),
          const SizedBox(height: 8),
          _buildSubjectGrid(),
        ],
      ),
    );
  }

  Widget _buildMasteryBanner() {
    final overall = _tracker.learner.overallMastery;
    final started = _tracker.learner.totalChaptersStarted;
    final mastered = _tracker.learner.totalChaptersCompleted;
    final sessions = _tracker.learner.totalStudySessions;
    final minutes = _tracker.learner.totalMinutesStudied;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall Mastery',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${(overall * 100).round()}%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: overall >= 0.7
                                    ? Colors.green
                                    : overall >= 0.4
                                        ? Colors.orange
                                        : Colors.red,
                              )),
                          const Spacer(),
                          _miniStat('$started', 'Started'),
                          _miniStat('$mastered', 'Mastered'),
                          _miniStat('$sessions', 'Sessions'),
                          _miniStat('${minutes}m', 'Time'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overall,
                minHeight: 8,
                color: overall >= 0.7
                    ? Colors.green
                    : overall >= 0.4
                        ? Colors.orange
                        : Colors.red,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, int count, Color color, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        Text('$count items', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildDueCards(List<dynamic> entries) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final entry = entries[i];
          final ch = allChapters.cast<Chapter?>().firstWhere(
              (c) => c!.id == entry.chapterId, orElse: () => null);
          if (ch == null) return const SizedBox.shrink();
          return _horizontalCard(
            ch.name,
            '${(entry.masteryScore * 100).round()}% • due: +${entry.interval}d',
            Colors.orange.shade50,
            Colors.orange.shade700,
            () => _openChapter(ch),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCards(List<Chapter> recommendations) {
    return Column(
      children: recommendations.map((ch) {
        final reasons = _engine.getReasonsForChapter(ch);
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openChapter(ch),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('${ch.weightage}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ch.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                            '${ch.subject} • ${ch.pages}p • ${reasons.take(2).join(' • ')}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('${_engine.calculateRecoveryTime(ch)} min',
                            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary)),
                        if (_tracker.learner.progress.containsKey(ch.id))
                          SizedBox(
                            width: 30,
                            child: LinearProgressIndicator(
                              value: _tracker.learner.progress[ch.id]!.masteryScore,
                              minHeight: 3,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeakCards(List<dynamic> entries) {
    return Column(
      children: entries.take(3).map((entry) {
        final ch = allChapters.cast<Chapter?>().firstWhere(
            (c) => c!.id == entry.chapterId, orElse: () => null);
        if (ch == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Card(
            color: Colors.red.shade50,
            child: ListTile(
              dense: true,
              leading: Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 22),
              title: Text(ch.name, style: const TextStyle(fontSize: 13)),
              subtitle: Text(
                'Accuracy: ${(entry.masteryScore * 100).round()}% • ${entry.retryCount} retries',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: SizedBox(
                width: 50,
                child: LinearProgressIndicator(
                  value: entry.masteryScore,
                  minHeight: 6,
                  color: Colors.red,
                  backgroundColor: Colors.red.shade100,
                ),
              ),
              onTap: () => _openChapter(ch),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectGrid() {
    final subjects = {'Physics': Icons.science, 'Chemistry': Icons.biotech, 'Mathematics': Icons.calculate, 'Biology': Icons.pets};
    final chapterCounts = <String, int>{};
    final masteryBySubject = <String, double>{};

    for (final ch in allChapters) {
      chapterCounts[ch.subject] = (chapterCounts[ch.subject] ?? 0) + 1;
      final p = _tracker.learner.progress[ch.id];
      masteryBySubject[ch.subject] =
          (masteryBySubject[ch.subject] ?? 0) + (p?.masteryScore ?? 0.0);
    }
    for (final s in masteryBySubject.keys) {
      masteryBySubject[s] = masteryBySubject[s]! / chapterCounts[s]!;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: subjects.length,
      itemBuilder: (ctx, i) {
        final name = subjects.keys.elementAt(i);
        final icon = subjects.values.elementAt(i);
        final count = chapterCounts[name] ?? 0;
        final mastery = masteryBySubject[name] ?? 0.0;
        final started = allChapters
            .where((c) => c.subject == name && _tracker.learner.progress.containsKey(c.id))
            .length;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _scrollToSubject(name),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$started/$count chapters',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: mastery,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _horizontalCard(String title, String subtitle, Color bg, Color fg, VoidCallback onTap) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: fg), maxLines: 2),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 11, color: fg.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }

  void _openChapter(Chapter chapter) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ChapterDetailScreen(
              chapter: chapter,
              engine: _engine,
              tracker: _tracker,
              onProgressUpdated: _onProgressUpdated,
            ),
          ),
        )
        .then((_) => _saveLearner());
  }

  void _openQuickQuiz() {
    final top = _engine.getTopRecommendations(count: 1);
    if (top.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(chapter: top.first, tracker: _tracker),
        ),
      );
    }
  }

  void _scrollToSubject(String subject) {}

  void _onProgressUpdated(LearnerModel updated) {
    setState(() {
      _engine = RecommendationEngine(
        chapters: allChapters,
        profile: widget.profile,
        learner: _tracker.learner,
      );
    });
  }
}
