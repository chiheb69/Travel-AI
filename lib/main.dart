import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/config.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/features/auth/bloc/auth_bloc.dart';
import 'package:travel_planner/features/auth/bloc/auth_event.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_bloc.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_event.dart';
import 'package:travel_planner/features/chat/bloc/chat_bloc.dart';
import 'package:travel_planner/repositories/auth_repository.dart';
import 'package:travel_planner/repositories/travel_repository.dart';
import 'package:travel_planner/ui/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (AppConfig.isFirebaseConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  print("Travel Planner App: STARTING v2.0 - Gemini Fix Active");
  runApp(const TravelPlannerApp());
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => TravelRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthStarted()),
          ),
          BlocProvider(
            create: (context) => DiscoveryBloc(
              travelRepository: context.read<TravelRepository>(),
            )..add(LoadFeaturedDestinations()),
          ),
          BlocProvider(
            create: (context) => ChatBloc(apiKey: AppConfig.geminiApiKey),
          ),
        ],
        child: MaterialApp(
          title: 'Travel Planner AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
