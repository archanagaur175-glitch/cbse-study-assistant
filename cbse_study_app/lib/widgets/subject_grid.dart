import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../data/chapters.dart';

class SubjectGrid extends StatelessWidget {
  final void Function(String subject)? onSubjectTap;

  const SubjectGrid({super.key, this.onSubjectTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subjects = {
      'Physics': Icons.science,
      'Chemistry': Icons.biotech,
      'Mathematics': Icons.calculate,
      'Biology': Icons.pets,
    };

    final chapterCounts = <String, int>{};
    final masteryBySubject = <String, double>{};
    for (final ch in allChapters) {
      chapterCounts[ch.subject] = (chapterCounts[ch.subject] ?? 0) + 1;
      final p = state.getProgressOrNull(ch.id);
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
            .where((c) =>
                c.subject == name && state.learner.progress.containsKey(c.id))
            .length;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSubjectTap?.call(name),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(icon,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$started/$count chapters',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey)),
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
}
