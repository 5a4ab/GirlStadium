import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'fixtures_screen.dart';
import 'learn_screen.dart';
import 'standings_screen.dart';
import 'news_screen.dart';

// This screen holds the bottom navigation bar and switches between
// the main tabs of the app.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // Keeps track of which tab is currently selected.
  int _selectedIndex = 0;

  // One slot per tab. A slot stays null until that tab is visited for
  // the first time, so FixturesScreen/LearnScreen/StandingsScreen/
  // NewsScreen (and the API requests their initState() methods
  // trigger) are only created when the user actually taps that tab -
  // not eagerly at app startup. Home is created right away since it's
  // the tab shown on launch.
  //
  // Once a slot is filled, the same widget instance is reused on every
  // rebuild, so IndexedStack keeps that screen's state (and Element)
  // alive when switching tabs instead of recreating it.
  final List<Widget?> _screens = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    _screens[0] = const HomeScreen();
  }

  // Builds the real screen widget for a given tab index. Only called
  // once per tab, the first time it's visited.
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const FixturesScreen();
      case 2:
        return const LearnScreen();
      case 3:
        return const StandingsScreen();
      case 4:
        return const NewsScreen();
      default:
        throw ArgumentError('Unknown tab index: $index');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Create the screen the first time this tab is visited. Already
      //-visited tabs (non-null slots) are left untouched so they
      // don't reload.
      _screens[index] ??= _buildScreen(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        // Not-yet-visited tabs render as an empty placeholder instead
        // of the real screen, so their initState() (and API requests)
        // never runs until the user taps that tab.
        children: [
          for (final screen in _screens) screen ?? const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: AppColors.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Fixtures',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Standings',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'News',
          ),
        ],
      ),
    );
  }
}