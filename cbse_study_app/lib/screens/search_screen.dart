import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/learner_model.dart';
import '../services/recommendation_engine.dart';
import '../services/progress_tracker.dart';
import 'chapter_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final RecommendationEngine engine;
  final ProgressTracker tracker;
  final void Function(LearnerModel) onProgressUpdated;

  const SearchScreen({
    super.key,
    required this.engine,
    required this.tracker,
    required this.onProgressUpdated,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryCtrl = TextEditingController();
  List<Chapter> _results = [];
  bool _hasSearched = false;

  void _search() {
    final q = _queryCtrl.text.trim();
    if (q.isEmpty) {
      setState(() { _results = []; _hasSearched = false; });
      return;
    }
    setState(() {
      _results = widget.engine.search(q);
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _queryCtrl,
              decoration: InputDecoration(
                hintText: 'Search chapters, formulas, notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _queryCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _queryCtrl.clear();
                        _search();
                      })
                    : null,
              ),
              onChanged: (_) => _search(),
            ),
          ),
          Expanded(
            child: _hasSearched && _results.isEmpty
                ? const Center(child: Text('No results found'))
                : !_hasSearched
                    ? _buildPopularGrid()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _results.length,
                        itemBuilder: (ctx, i) {
                          final ch = _results[i];
                          final progress = widget.tracker.getProgress(ch.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Card(
                              child: ListTile(
                                title: Text(ch.name, style: const TextStyle(fontSize: 14)),
                                subtitle: Text('${ch.subject} • ${ch.pages}p • ${ch.weightage}% weightage',
                                    style: const TextStyle(fontSize: 11)),
                                trailing: progress.masteryScore > 0
                                    ? SizedBox(
                                        width: 40,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            LinearProgressIndicator(
                                              value: progress.masteryScore,
                                              minHeight: 4,
                                            ),
                                            const SizedBox(height: 2),
                                            Text('${(progress.masteryScore * 100).round()}%',
                                                style: const TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      )
                                    : const Icon(Icons.chevron_right, size: 20),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChapterDetailScreen(
                                      chapter: ch,
                                      engine: widget.engine,
                                      tracker: widget.tracker,
                                      onProgressUpdated: widget.onProgressUpdated,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGrid() {
    final popular = widget.engine.getTopRecommendations(count: 6);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: popular.length,
      itemBuilder: (ctx, i) {
        final ch = popular[i];
        final progress = widget.tracker.getProgress(ch.id);
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChapterDetailScreen(
                  chapter: ch,
                  engine: widget.engine,
                  tracker: widget.tracker,
                  onProgressUpdated: widget.onProgressUpdated,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ch.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2),
                  const SizedBox(height: 4),
                  Text(ch.subject, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (progress.masteryScore > 0) ...[
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: progress.masteryScore, minHeight: 3),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
