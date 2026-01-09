import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/features/auth/bloc/auth_bloc.dart';
import 'package:travel_planner/features/auth/bloc/auth_event.dart';
import 'package:travel_planner/features/auth/bloc/auth_state.dart';
import 'package:travel_planner/features/discovery/ui/dashboard_screen.dart';
import 'package:travel_planner/ui/widgets/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
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
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'Create\nAccount',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 48,
                                height: 1.1,
                              ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInLeft(
                        delay: const Duration(milliseconds: 200),
                        child: CustomTextField(
                          hintText: 'Full Name',
                          icon: Icons.person_outline,
                          controller: _nameController,
                        ),
                      ),
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
                      const SizedBox(height: 32),
                      FadeInUp(
                        delay: const Duration(milliseconds: 800),
                        child: CustomButton(
                          text: 'Sign Up',
                          isLoading: state is AuthLoading,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  AuthSignUpRequested(
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
                          delay: const Duration(milliseconds: 900),
                          child: Text(
                            'OR',
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1000),
                        child: SocialButton(
                          text: 'Sign Up with Google',
                          icon: Icons.g_mobiledata_rounded,
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: FadeIn(
                          delay: const Duration(milliseconds: 1200),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.white.withOpacity(0.5)),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Log In',
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
