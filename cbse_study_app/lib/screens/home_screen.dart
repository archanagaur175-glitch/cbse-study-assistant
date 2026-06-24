import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/profile.dart';
import '../models/learner_model.dart';
import '../data/chapters.dart';
import '../services/recommendation_engine.dart';
import '../storage/user_progress.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chapter_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Profile profile;
  final LearnerModel learner;
  const HomeScreen({super.key, required this.profile, required this.learner});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RecommendationEngine _engine;
  late LearnerModel _learner;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _learner = widget.learner;
    _engine = RecommendationEngine(
      chapters: allChapters,
      profile: widget.profile,
      learner: _learner,
    );
  }

  Future<void> _saveLearner() async {
    await UserProgressStore.save(_learner);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      SearchScreen(
        recommender: _engine,
        learner: _learner,
        onProgressUpdated: _onProgressUpdated,
      ),
      ProfileScreen(profile: widget.profile, learner: _learner),
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
    final recommendations = _engine.getTopRecommendations(count: 5);
    final dueReviews = _learner.dueReviews;
    final weakTopics = _learner.weakestTopics;
    final nextChapter = _recommendNext();

    final bySubject = <String, List<Chapter>>{};
    for (final ch in allChapters) {
      bySubject.putIfAbsent(ch.subject, () => []).add(ch);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hi, ${widget.profile.name}'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMasteryCard(),
          const SizedBox(height: 12),
          if (nextChapter != null) ...[
            _buildNextChapterCard(nextChapter),
            const SizedBox(height: 12),
          ],
          if (dueReviews.isNotEmpty) ...[
            _buildDueReviewsCard(dueReviews),
            const SizedBox(height: 12),
          ],
          _buildRecommendationsCard(recommendations),
          const SizedBox(height: 12),
          if (weakTopics.isNotEmpty) ...[
            _buildWeakTopicsCard(weakTopics),
            const SizedBox(height: 12),
          ],
          _buildStudyPlanCard(),
          const SizedBox(height: 12),
          ...bySubject.entries.map((entry) => _buildSubjectCard(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildMasteryCard() {
    final overall = _learner.overallMastery;
    final started = _learner.totalChaptersStarted;
    final completed = _learner.totalChaptersCompleted;
    final sessions = _learner.totalStudySessions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat(Icons.auto_stories, '$started', 'Started'),
                _stat(Icons.check_circle, '$completed', 'Mastered'),
                _stat(Icons.timer, '${_learner.totalMinutesStudied}m', 'Studied'),
                _stat(Icons.repeat, '$sessions', 'Sessions'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: overall,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 4),
            Text('Overall Mastery: ${(overall * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Chapter? _recommendNext() {
    final next = _engine.getTopRecommendations(count: 1);
    return next.isNotEmpty ? next.first : null;
  }

  Widget _buildNextChapterCard(Chapter chapter) {
    final reasons = _engine.getReasonsForChapter(chapter);
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.auto_awesome),
        title: const Text('Recommended Next', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${chapter.name}\n${reasons.take(2).join(' • ')}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openChapter(chapter),
      ),
    );
  }

  Widget _buildDueReviewsCard(List<dynamic> entries) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text('Due for Review (${entries.length})',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...entries.take(3).map((entry) {
              final ch = allChapters.cast<Chapter?>().firstWhere(
                  (c) => c!.id == entry.chapterId, orElse: () => null);
              if (ch == null) return const SizedBox.shrink();
              return ListTile(
                dense: true,
                title: Text(ch.name, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                    'Mastery: ${(entry.masteryScore * 100).round()}%'),
                trailing: Text('+${entry.interval}d',
                    style: TextStyle(color: Colors.orange.shade700)),
                onTap: () => _openChapter(ch),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(List<Chapter> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recommended for You',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...recommendations.map((ch) {
              final reasons = _engine.getReasonsForChapter(ch);
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text('${ch.weightage}', style: const TextStyle(fontSize: 11))),
                title: Text(ch.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                    '${ch.subject} • ${ch.pages}p\n${reasons.take(2).join(' • ')}',
                    style: const TextStyle(fontSize: 11)),
                trailing: Text('${_engine.calculateRecoveryTime(ch)} min',
                    style: Theme.of(context).textTheme.bodySmall),
                onTap: () => _openChapter(ch),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeakTopicsCard(List<dynamic> entries) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Text('Weakest Topics', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...entries.map((entry) {
              final ch = allChapters.cast<Chapter?>().firstWhere(
                  (c) => c!.id == entry.chapterId, orElse: () => null);
              if (ch == null) return const SizedBox.shrink();
              return ListTile(
                dense: true,
                title: Text(ch.name, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                    'Accuracy: ${(entry.masteryScore * 100).round()}% • ${entry.retryCount} retries'),
                trailing: Icon(Icons.chevron_right, size: 18),
                onTap: () => _openChapter(ch),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyPlanCard() {
    final plan = allChapters
        .where((c) => _learner.progress.containsKey(c.id) &&
            _learner.progress[c.id]!.masteryScore < 0.8)
        .take(3)
        .toList();
    if (plan.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text('Continue Studying',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...plan.map((ch) {
              final entry = _learner.progress[ch.id]!;
              return ListTile(
                dense: true,
                title: Text(ch.name, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                    '${(entry.masteryScore * 100).round()}% complete'),
                trailing: SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    value: entry.masteryScore,
                    minHeight: 6,
                  ),
                ),
                onTap: () => _openChapter(ch),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String subject, List<Chapter> chapters) {
    final started = chapters.where((c) => _learner.progress.containsKey(c.id)).length;
    final avgMastery = chapters.fold(0.0, (s, c) {
      final p = _learner.progress[c.id];
      return s + (p?.masteryScore ?? 0.0);
    }) / chapters.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(subject, style: Theme.of(context).textTheme.titleMedium),
                Text('$started/${chapters.length} • ${(avgMastery * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            ...chapters.map((ch) {
              final entry = _learner.progress[ch.id];
              final mastery = entry?.masteryScore ?? 0.0;
              return ListTile(
                title: Text(ch.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text('${ch.pages}p • ${ch.weightage}% weightage'),
                trailing: entry != null
                    ? SizedBox(
                        width: 40,
                        child: LinearProgressIndicator(value: mastery, minHeight: 4),
                      )
                    : const Icon(Icons.chevron_right, size: 18),
                dense: true,
                onTap: () => _openChapter(ch),
              );
            }),
          ],
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
              learner: _learner,
              onProgressUpdated: _onProgressUpdated,
            ),
          ),
        )
        .then((_) => _saveLearner());
  }

  void _onProgressUpdated(LearnerModel updated) {
    setState(() {
      _learner = updated;
      _engine = RecommendationEngine(
        chapters: allChapters,
        profile: widget.profile,
        learner: _learner,
      );
    });
  }
}
