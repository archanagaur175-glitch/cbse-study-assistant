import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/learner_model.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserCard(context),
          const SizedBox(height: 16),
          _buildProgressCard(context),
          const SizedBox(height: 16),
          _buildStudyDetailsCard(context),
          const SizedBox(height: 16),
          _buildSubjectsCard(context),
          const SizedBox(height: 24),
          _buildResetButton(context),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 12),
            Text(profile.name, style: Theme.of(context).textTheme.headlineSmall),
            Text(profile.grade, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
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
            Text('Learning Progress', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _progressRow('Overall Mastery', overall, overall),
            const SizedBox(height: 8),
            _detailRow('Chapters Started', '$started'),
            _detailRow('Chapters Mastered', '$completed'),
            _detailRow('Due for Review', '$dueCount'),
            _detailRow('Study Sessions', '$sessions'),
            _detailRow('Total Time', '${learner.totalMinutesStudied} min'),
            _detailRow('Last Active',
                _fmtDate(learner.lastActive)),
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
            Text('Study Settings', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _detailRow('Daily Study', '${profile.dailyStudyMinutes} min'),
            _detailRow('Exam Goal', _cap(profile.examGoal)),
            _detailRow('Difficulty', _cap(profile.difficulty)),
            _detailRow('Note Length', _cap(profile.noteLength)),
          ],
        ),
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
            const Divider(),
            Text('Weak Subjects:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: profile.weakSubjects.isEmpty
                  ? [const Chip(label: Text('None'))]
                  : profile.weakSubjects
                      .map((s) => Chip(label: Text(s), backgroundColor: Colors.red.shade100))
                      .toList(),
            ),
            const SizedBox(height: 12),
            Text('Strong Subjects:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: profile.strongSubjects.isEmpty
                  ? [const Chip(label: Text('None'))]
                  : profile.strongSubjects
                      .map((s) => Chip(label: Text(s), backgroundColor: Colors.green.shade100))
                      .toList(),
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
      icon: const Icon(Icons.refresh),
      label: const Text('Reset Profile & Progress'),
    );
  }

  Widget _progressRow(String label, double value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${(value * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  String _cap(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  String _fmtDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
