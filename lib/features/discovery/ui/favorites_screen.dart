import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_bloc.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_state.dart';
import 'package:travel_planner/features/discovery/ui/dashboard_screen.dart';
import 'package:travel_planner/features/discovery/ui/destination_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state is DiscoveryLoaded) {
            final favorites = state.favorites;
            
            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start exploring to add some!',
                      style: TextStyle(color: Colors.white.withOpacity(0.3)),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationDetailsScreen(destination: favorites[index]),
                        ),
                      );
                    },
                    child: DestinationCard(destination: favorites[index]),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
        },
      ),
    );
  }
}
