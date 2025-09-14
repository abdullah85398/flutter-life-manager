import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../features/auth/auth_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/planner_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/fixed_commitments/presentation/fixed_commitments_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/settings/settings_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.calendar_today,
      label: 'Planner',
      screen: const PlannerScreen(),
    ),
    NavigationItem(
      icon: Icons.flag,
      label: 'Goals',
      screen: const GoalsScreen(),
    ),
    NavigationItem(
      icon: Icons.folder,
      label: 'Projects',
      screen: const ProjectsScreen(),
    ),
    NavigationItem(
      icon: Icons.schedule,
      label: 'Commitments',
      screen: const FixedCommitmentsScreen(),
    ),
    NavigationItem(
      icon: Icons.insights,
      label: 'Insights',
      screen: const InsightsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return authState.when(
      data: (user) {
        if (user == null) {
          return const AuthScreen();
        }
        
        // Check if user needs onboarding
        // This would typically check user preferences or completion status
        // For now, we'll assume onboarding is complete
        
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _navigationItems.map((item) => item.screen).toList(),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: colorScheme.surface,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurfaceVariant,
              selectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              elevation: 0,
              items: _navigationItems.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon),
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}