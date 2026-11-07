import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_theme.dart';
import 'state/app_state.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home_dashboard/home_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ClarityCrewApp());
}

class ClarityCrewApp extends StatelessWidget {
  const ClarityCrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      child: MaterialApp(
        title: 'ClarityCrew',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const AppBootstrap(),
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _ready = false;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final state = AppStateProvider.of(context);
    await state.hydrate();
    setState(() {
      _ready = true;
      _hasProfile = state.learnerProfile != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              Text(
                'ClarityCrew',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    return _hasProfile
        ? const HomeDashboardScreen()
        : const OnboardingScreen();
  }
}
