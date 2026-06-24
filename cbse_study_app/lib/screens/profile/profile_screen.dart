import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../data/chapters.dart';
import '../../app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final learner = state.learner;
    final totalStarted = state.totalChaptersStarted;
    final totalDone = state.totalChaptersCompleted;
    final overall = state.overallMastery;
    final total = allChapters.length;

    final subjectMastery = <String, double>{};
    for (final subject in ['Physics', 'Chemistry', 'Mathematics', 'Biology']) {
      final chapters = allChapters.where((c) => c.subject == subject);
      final entries = chapters
          .map((c) => state.getProgressOrNull(c.id))
          .where((p) => p != null)
          .toList();
      subjectMastery[subject] = entries.isEmpty
          ? 0.0
          : entries.fold(0.0, (s, p) => s + p!.masteryScore) / entries.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Reset progress',
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 28,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(profile.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Grade ${profile.grade}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('$totalStarted', 'Started'),
                      _stat('$totalDone/$total', 'Mastered'),
                      _stat('${(overall * 100).round()}%', 'Mastery'),
                      _stat('${learner.totalStudySessions}', 'Sessions'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject Mastery',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...subjectMastery.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontSize: 13)),
                                Text('${(entry.value * 100).round()}%',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: entry.value,
                                minHeight: 6,
                                color: entry.value >= 0.7
                                    ? Colors.green
                                    : entry.value >= 0.4
                                        ? Colors.orange
                                        : Colors.red,
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          if (profile.weakSubjects.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus Areas (Weak Subjects)',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: profile.weakSubjects
                          .map((s) => Chip(
                              label: Text(s, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.red.withOpacity(0.1)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
            'This will erase all your study data. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                context.read<AppState>().clearAll();
                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const _ResetApp()),
                    (_) => false);
              },
              child: const Text('Reset')),
        ],
      ),
    );
  }
}

class _ResetApp extends StatelessWidget {
  const _ResetApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Progress reset successfully'),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) {
                      final state = AppState.createNew(
                        context.read<AppState>().profile,
                      );
                      return ChangeNotifierProvider.value(
                        value: state,
                        child: const _MainAppShell(),
                      );
                    }),
                    (_) => false,
                  );
                },
                child: const Text('Start Fresh')),
          ],
        ),
      ),
    );
  }
}

class _MainAppShell extends StatelessWidget {
  const _MainAppShell();

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}
