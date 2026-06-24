import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../data/chapters.dart';
import '../../models/chapter.dart';
import '../chapter/chapter_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final results = _query.isEmpty
        ? allChapters
        : allChapters
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()) ||
                c.subject.toLowerCase().contains(_query.toLowerCase()) ||
                c.detailedNotes.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    final subjects = {
      'Physics': Icons.science,
      'Chemistry': Icons.biotech,
      'Mathematics': Icons.calculate,
      'Biology': Icons.pets,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search chapters, topics...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (_query.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Browse by Subject',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subjects.entries.map((entry) {
                      final count = allChapters
                          .where((c) => c.subject == entry.key)
                          .length;
                      return ActionChip(
                        avatar: Icon(entry.value, size: 16),
                        label: Text('${entry.key} ($count)'),
                        onPressed: () => setState(() => _query = entry.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Popular Chapters',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          Expanded(
            child: _query.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: allChapters
                        .where((c) => ['Newton\'s Laws of Motion', 'Chemical Reactions', 'Quadratic Equations', 'Cell Biology'].contains(c.name))
                        .map((ch) => _resultTile(context, state, ch))
                        .toList(),
                  )
                : results.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: results
                            .map((ch) => _resultTile(context, state, ch))
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _resultTile(BuildContext context, AppState state, Chapter ch) {
    final progress = state.getProgressOrNull(ch.id);
    final mastery = progress?.masteryScore ?? 0.0;
    return Card(
      child: ListTile(
        title: Text(ch.name, style: const TextStyle(fontSize: 14)),
        subtitle: Row(
          children: [
            Text(ch.subject, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const Spacer(),
            if (mastery > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: mastery >= 0.7
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${(mastery * 100).round()}%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: mastery >= 0.7 ? Colors.green : Colors.orange)),
              ),
          ],
        ),
        leading: CircleAvatar(
          radius: 16,
          child: Text(ch.id.toString(), style: const TextStyle(fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<AppState>(),
              child: ChapterDetailScreen(chapterId: ch.id),
            ),
          ));
        },
      ),
    );
  }
}
