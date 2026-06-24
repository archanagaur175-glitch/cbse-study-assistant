import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/learner_model.dart';
import '../utils/storage.dart';
import '../storage/user_progress.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _grade = 'Class 12';
  final _weakSubjects = <String>[];
  final _strongSubjects = <String>[];
  int _dailyMinutes = 60;
  String _examGoal = 'board';
  String _difficulty = 'medium';
  String _noteLength = 'medium';

  final _subjects = ['Physics', 'Chemistry', 'Mathematics', 'Biology'];
  final _grades = ['Class 11', 'Class 12'];
  final _goals = ['board', 'competitive', 'foundation'];
  final _difficulties = ['easy', 'medium', 'hard'];
  final _noteLengths = ['short', 'medium', 'long'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = Profile(
      name: _nameCtrl.text.trim(),
      grade: _grade,
      weakSubjects: _weakSubjects,
      strongSubjects: _strongSubjects,
      dailyStudyMinutes: _dailyMinutes,
      examGoal: _examGoal,
      difficulty: _difficulty,
      noteLength: _noteLength,
    );
    await Storage.saveProfile(profile);
    final learner = await UserProgressStore.loadOrCreate(profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(profile: profile, learner: learner)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _grade,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
              items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _grade = v!),
            ),
            const SizedBox(height: 16),
            const Text('Weak Subjects (tap to select)'),
            Wrap(
              spacing: 8,
              children: _subjects.map((s) {
                final sel = _weakSubjects.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: sel,
                  onSelected: (v) {
                    setState(() {
                      if (v) { _weakSubjects.add(s); } else { _weakSubjects.remove(s); }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Strong Subjects (tap to select)'),
            Wrap(
              spacing: 8,
              children: _subjects.map((s) {
                final sel = _strongSubjects.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: sel,
                  onSelected: (v) {
                    setState(() {
                      if (v) { _strongSubjects.add(s); } else { _strongSubjects.remove(s); }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _examGoal,
              decoration: const InputDecoration(
                labelText: 'Exam Goal',
                border: OutlineInputBorder(),
              ),
              items: _goals.map((g) => DropdownMenuItem(
                value: g,
                child: Text(g[0].toUpperCase() + g.substring(1)),
              )).toList(),
              onChanged: (v) => setState(() => _examGoal = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                labelText: 'Preferred Difficulty',
                border: OutlineInputBorder(),
              ),
              items: _difficulties.map((d) => DropdownMenuItem(
                value: d,
                child: Text(d[0].toUpperCase() + d.substring(1)),
              )).toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _noteLength,
              decoration: const InputDecoration(
                labelText: 'Note Length Preference',
                border: OutlineInputBorder(),
              ),
              items: _noteLengths.map((n) => DropdownMenuItem(
                value: n,
                child: Text(n[0].toUpperCase() + n.substring(1)),
              )).toList(),
              onChanged: (v) => setState(() => _noteLength = v!),
            ),
            const SizedBox(height: 16),
            Text('Daily Study Time: $_dailyMinutes min'),
            Slider(
              value: _dailyMinutes.toDouble(),
              min: 15,
              max: 300,
              divisions: 19,
              label: '$_dailyMinutes min',
              onChanged: (v) => setState(() => _dailyMinutes = v.round()),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save & Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
