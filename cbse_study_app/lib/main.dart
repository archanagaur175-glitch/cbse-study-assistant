import 'package:flutter/material.dart';
import 'models/profile.dart';
import 'models/learner_model.dart';
import 'utils/storage.dart';
import 'storage/user_progress.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() => runApp(const CbseStudyApp());

class CbseStudyApp extends StatelessWidget {
  const CbseStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CBSE Study Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A73E8),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final profile = await Storage.loadProfile();
    if (!mounted) return;
    if (profile == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      final learner = await UserProgressStore.loadOrCreate(profile);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(profile: profile, learner: learner),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
