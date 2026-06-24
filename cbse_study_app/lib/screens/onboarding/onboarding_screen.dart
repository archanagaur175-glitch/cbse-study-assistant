import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/profile.dart';
import '../../state/app_state.dart';
import '../../app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _grade = '10';
  List<String> _weakSubjects = [];
  List<String> _strongSubjects = [];
  int _dailyMinutes = 30;
  String _examGoal = 'board';
  String _difficulty = 'medium';
  String _noteLength = 'medium';

  final _allSubjects = ['Physics', 'Chemistry', 'Mathematics', 'Biology'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
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
    final state = AppState.createNew(profile);
    state.saveProfile();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: state,
        child: const _HomeShell(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Let\'s personalize your study experience',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _grade,
              decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school)),
              items: ['9', '10', '11', '12']
                  .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
                  .toList(),
              onChanged: (v) => setState(() => _grade = v!),
            ),
            const SizedBox(height: 12),
            const Text('Which subjects do you find difficult?',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _allSubjects.map((s) {
                final selected = _weakSubjects.contains(s);
                return FilterChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  selectedColor: Colors.red.withOpacity(0.2),
                  onSelected: (v) => setState(() {
                    v ? _weakSubjects.add(s) : _weakSubjects.remove(s);
                    _strongSubjects.remove(s);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Which are your strong subjects?',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _allSubjects.map((s) {
                final selected = _strongSubjects.contains(s);
                return FilterChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  selectedColor: Colors.green.withOpacity(0.2),
                  onSelected: (v) => setState(() {
                    v ? _strongSubjects.add(s) : _strongSubjects.remove(s);
                    _weakSubjects.remove(s);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Daily study time: $_dailyMinutes minutes',
                style: TextStyle(fontSize: 13)),
            Slider(
              value: _dailyMinutes.toDouble(),
              min: 10,
              max: 240,
              divisions: 23,
              label: '$_dailyMinutes min',
              onChanged: (v) => setState(() => _dailyMinutes = v.round()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _examGoal,
              decoration: const InputDecoration(
                  labelText: 'Exam Goal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag)),
              items: const [
                DropdownMenuItem(value: 'board', child: Text('Board Exams')),
                DropdownMenuItem(value: 'competitive', child: Text('Competitive Exams')),
                DropdownMenuItem(value: 'school', child: Text('School Tests')),
              ],
              onChanged: (v) => setState(() => _examGoal = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                  labelText: 'Preferred Difficulty',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tune)),
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Easy')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'hard', child: Text('Hard')),
              ],
              onChanged: (v) => setState(() => _difficulty = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _noteLength,
              decoration: const InputDecoration(
                  labelText: 'Note Length',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes)),
              items: const [
                DropdownMenuItem(value: 'short', child: Text('Short (bullet points)')),
                DropdownMenuItem(value: 'medium', child: Text('Medium (concise)')),
                DropdownMenuItem(value: 'long', child: Text('Long (detailed)')),
              ],
              onChanged: (v) => setState(() => _noteLength = v!),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Start Learning'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell();

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}
