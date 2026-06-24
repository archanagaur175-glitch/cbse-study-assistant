import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CBSEStudyApp());
}

class CBSEStudyApp extends StatelessWidget {
  const CBSEStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CBSE Study Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const _StartupScreen(),
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  Future<AppState?>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = AppState.loadFromDisk();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState?>(
      future: _loadFuture,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final state = snap.data;
        if (state == null) {
          return const OnboardingScreen();
        }
        return ChangeNotifierProvider.value(
          value: state,
          child: const AppShell(),
        );
      },
    );
  }
}
