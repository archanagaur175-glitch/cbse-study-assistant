import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/learner_model.dart';
import '../models/chapter.dart';
import '../data/chapters.dart';
import '../utils/storage.dart';
import '../storage/user_progress.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Profile profile;
  final LearnerModel learner;
  const ProfileScreen({super.key, required this.profile, required this.learner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          _buildUserCard(context),
          const SizedBox(height: 12),
          _buildProgressSummary(context),
          const SizedBox(height: 12),
          _buildSubjectMastery(context),
          const SizedBox(height: 12),
          _buildStudyDetailsCard(context),
          const SizedBox(height: 12),
          _buildSubjectsCard(context),
          const SizedBox(height: 16),
          _buildResetButton(context),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(profile.grade, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary(BuildContext context) {
    final overall = learner.overallMastery;
    final started = learner.totalChaptersStarted;
    final completed = learner.totalChaptersCompleted;
    final dueCount = learner.dueReviews.length;
    final sessions = learner.totalStudySessions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Learning Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard('$started', 'Started', Icons.auto_stories, Colors.blue)),
                Expanded(child: _statCard('$completed', 'Mastered', Icons.check_circle, Colors.green)),
                Expanded(child: _statCard('$dueCount', 'Due', Icons.notifications_active, Colors.orange)),
                Expanded(child: _statCard('$sessions', 'Sessions', Icons.repeat, Colors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overall Mastery', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text('${(overall * 100).round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: overall >= 0.7 ? Colors.green : overall >= 0.4 ? Colors.orange : Colors.red,
                    )),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overall,
                minHeight: 8,
                color: overall >= 0.7 ? Colors.green : overall >= 0.4 ? Colors.orange : Colors.red,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _detailText('Total Time', '${learner.totalMinutesStudied} min'),
                _detailText('Last Active', _fmtDate(learner.lastActive)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSubjectMastery(BuildContext context) {
    final subjects = ['Physics', 'Chemistry', 'Mathematics', 'Biology'];
    final subjectData = subjects.map((s) {
      final chapters = allChapters.where((c) => c.subject == s).toList();
      final started = chapters.where((c) => learner.progress.containsKey(c.id)).length;
      final avgMastery = chapters.fold(0.0, (sum, c) {
        final p = learner.progress[c.id];
        return sum + (p?.masteryScore ?? 0.0);
      }) / chapters.length;
      return (name: s, started: started, total: chapters.length, mastery: avgMastery);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject Progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...subjectData.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(d.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text('${d.started}/${d.total} • ${(d.mastery * 100).round()}%',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: d.mastery,
                          minHeight: 6,
                          color: d.mastery >= 0.7
                              ? Colors.green
                              : d.mastery >= 0.4
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
    );
  }

  Widget _buildStudyDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _settingRow(Icons.timer_outlined, 'Daily Study', '${profile.dailyStudyMinutes} min'),
            _settingRow(Icons.flag_outlined, 'Exam Goal', _cap(profile.examGoal)),
            _settingRow(Icons.speed_outlined, 'Difficulty', _cap(profile.difficulty)),
            _settingRow(Icons.article_outlined, 'Notes', _cap(profile.noteLength)),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subjects', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: profile.weakSubjects.map((s) => Chip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.red.shade50,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            if (profile.weakSubjects.isNotEmpty) const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: profile.strongSubjects.map((s) => Chip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.green.shade50,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await UserProgressStore.clear(profile.name);
        await Storage.clearProfile();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (_) => false,
        );
      },
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Reset All Progress'),
    );
  }

  Widget _detailText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ],
    );
  }

  String _cap(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  String _fmtDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
