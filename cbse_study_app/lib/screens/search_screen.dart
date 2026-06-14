import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../utils/recommender.dart';
import 'chapter_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final Recommender recommender;
  const SearchScreen({super.key, required this.recommender});

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
      _results = widget.recommender.search(q);
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
      appBar: AppBar(title: const Text('Search Chapters'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _queryCtrl,
              decoration: InputDecoration(
                hintText: 'Search chapters, formulas, notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final ch = _results[i];
                      return Card(
                        child: ListTile(
                          title: Text(ch.name),
                          subtitle: Text('${ch.subject} • ${ch.pages} pages'),
                          trailing: Text('${ch.weightage}%', style: Theme.of(context).textTheme.bodySmall),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ChapterDetailScreen(
                              chapter: ch, recommender: widget.recommender,
                            )),
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
}
