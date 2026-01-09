import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/features/auth/bloc/auth_bloc.dart';
import 'package:travel_planner/features/auth/bloc/auth_state.dart';
import 'package:travel_planner/features/auth/ui/login_screen.dart';
import 'package:travel_planner/features/discovery/ui/dashboard_screen.dart';
import 'package:travel_planner/features/admin/ui/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only navigate after splash animation/delay
        Future.delayed(const Duration(milliseconds: 3000), () {
          if (!mounted) return;
          if (state is AuthAuthenticated) {
            if (state.user.email == 'admin@app.tn') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            }
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            FadeInDown(
              duration: const Duration(milliseconds: 1000),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  size: 80,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Text(
                'TRAVEL AI',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      letterSpacing: 4,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: Text(
                'Plan your next adventure with Gemini',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 48),
            FadeIn(
              delay: const Duration(milliseconds: 1500),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
