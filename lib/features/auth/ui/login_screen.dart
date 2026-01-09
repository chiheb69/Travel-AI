import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/features/auth/bloc/auth_bloc.dart';
import 'package:travel_planner/features/auth/bloc/auth_event.dart';
import 'package:travel_planner/features/auth/bloc/auth_state.dart';
import 'package:travel_planner/features/auth/ui/signup_screen.dart';
import 'package:travel_planner/features/discovery/ui/dashboard_screen.dart';
import 'package:travel_planner/features/admin/ui/admin_dashboard.dart';
import 'package:travel_planner/ui/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
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
                }
                if (state is AuthFailure) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error), backgroundColor: Colors.redAccent),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'Welcome\nBack!',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 48,
                                height: 1.1,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Plan your next escape.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 60),
                      FadeInLeft(
                        delay: const Duration(milliseconds: 400),
                        child: CustomTextField(
                          hintText: 'Email Address',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                        ),
                      ),
                      FadeInLeft(
                        delay: const Duration(milliseconds: 600),
                        child: CustomTextField(
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          isPassword: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FadeIn(
                          delay: const Duration(milliseconds: 800),
                          child: TextButton(
                            onPressed: () {
                              // Handle password recovery
                            },
                            child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.accentColor)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1000),
                        child: CustomButton(
                          text: 'Log In',
                          isLoading: state is AuthLoading,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  AuthLoginRequested(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: FadeIn(
                          delay: const Duration(milliseconds: 1100),
                          child: Text(
                            'OR',
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1200),
                        child: SocialButton(
                          text: 'Continue with Google',
                          icon: Icons.g_mobiledata_rounded, // Best fit for an icon without external assets
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: FadeIn(
                          delay: const Duration(milliseconds: 1400),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.white.withOpacity(0.5)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
