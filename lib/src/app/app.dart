import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../features/splash/splash_screen.dart';
import 'main_navigation.dart';

class LifeManagerApp extends StatelessWidget {
  const LifeManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeManager',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(), // Will navigate to MainNavigation after initialization
      routes: {
        '/main': (context) => const MainNavigation(),
      },
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('LifeManager', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          // Artistic gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.12),
                  cs.tertiary.withOpacity(0.10),
                  cs.secondary.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),

          // Foreground content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soft, artistic hero text
                Text(
                  'Plan. Focus. Reflect.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).moveY(begin: 20, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                Text(
                  'Minimal clicks. Beautiful insights.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ).animate().fadeIn(duration: 450.ms),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _CTAButton(label: 'Get Started', icon: Icons.play_circle_fill),
                    _CTAButton(label: 'Planner', icon: Icons.bubble_chart),
                    _CTAButton(label: 'Insights', icon: Icons.pie_chart_rounded),
                  ],
                ).animate().fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CTAButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 2,
        shadowColor: cs.shadow.withOpacity(0.2),
      ),
    );
  }
}