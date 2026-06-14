import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../utils/storage.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Profile profile;
  const ProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Study Details', style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  _detailRow('Daily Study', '${profile.dailyStudyMinutes} min'),
                  _detailRow('Exam Goal', profile.examGoal[0].toUpperCase() + profile.examGoal.substring(1)),
                  _detailRow('Difficulty', profile.difficulty[0].toUpperCase() + profile.difficulty.substring(1)),
                  _detailRow('Note Length', profile.noteLength[0].toUpperCase() + profile.noteLength.substring(1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
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
                        : profile.weakSubjects.map((s) => Chip(label: Text(s), backgroundColor: Colors.red.shade100)).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text('Strong Subjects:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: profile.strongSubjects.isEmpty
                        ? [const Chip(label: Text('None'))]
                        : profile.strongSubjects.map((s) => Chip(label: Text(s), backgroundColor: Colors.green.shade100)).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await Storage.clearProfile();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Profile'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w500))],
      ),
    );
  }
}
