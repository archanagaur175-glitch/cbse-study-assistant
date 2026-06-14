import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/profile.dart';
import '../data/chapters.dart';
import '../utils/recommender.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chapter_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Profile profile;
  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Recommender _recommender;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _recommender = Recommender(chapters: allChapters, profile: widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      SearchScreen(recommender: _recommender),
      ProfileScreen(profile: widget.profile),
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
    final recommendations = _recommender.getTopRecommendations(count: 5);
    final bySubject = <String, List<Chapter>>{};
    for (final ch in allChapters) {
      bySubject.putIfAbsent(ch.subject, () => []).add(ch);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hi, ${widget.profile.name}'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recommended for You', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...recommendations.map((ch) => ListTile(
                    leading: CircleAvatar(child: Text('${ch.weightage}')),
                    title: Text(ch.name, style: const TextStyle(fontSize: 14)),
                    subtitle: Text('${ch.subject} • ${ch.pages} pages'),
                    trailing: Text('${_recommender.calculateRecoveryTime(ch)} min',
                        style: Theme.of(context).textTheme.bodySmall),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChapterDetailScreen(
                        chapter: ch, recommender: _recommender,
                      )),
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...bySubject.entries.map((entry) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...entry.value.map((ch) => ListTile(
                      title: Text(ch.name, style: const TextStyle(fontSize: 14)),
                      subtitle: Text('${ch.pages} pages • ${ch.weightage}% weightage'),
                      trailing: const Icon(Icons.chevron_right),
                      dense: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ChapterDetailScreen(
                          chapter: ch, recommender: _recommender,
                        )),
                      ),
                    )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
