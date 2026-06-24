import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/profile/profile_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pages = const [
      HomeScreen(),
      SearchScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: state.tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.tabIndex,
        onDestinationSelected: (i) => state.setTab(i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
