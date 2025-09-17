import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

/// Main Navigation Screen
///
/// This screen provides the primary navigation shell for the FinGoal AI app.
/// It uses a PageView with bottom navigation to allow users to swipe between
/// the Chat and Dashboard sections of the application.
///
/// Features:
/// - Horizontal swipe navigation between Chat and Dashboard
/// - Bottom navigation bar with visual indicators
/// - Synchronized navigation state between swipe and tap
/// - Material Design 3 theming throughout
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  // Navigation items configuration
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: '', // Will be replaced with localized string
    ),
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: '', // Will be replaced with localized string
    ),
  ];

  // Screen widgets
  static const List<Widget> _screens = [
    ChatScreen(),
    DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handle page change from swipe gesture
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Handle navigation tap
  void _onNavigationTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Animate to the selected page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.account_circle_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: l10n.profile,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationTapped,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        destinations: [
          NavigationDestination(
            icon: Icon(_currentIndex == 0
                ? _navigationItems[0].activeIcon
                : _navigationItems[0].icon),
            label: l10n.chat,
          ),
          NavigationDestination(
            icon: Icon(_currentIndex == 1
                ? _navigationItems[1].activeIcon
                : _navigationItems[1].icon),
            label: l10n.dashboard,
          ),
        ],
      ),
    );
  }
}

/// Navigation item configuration class
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
