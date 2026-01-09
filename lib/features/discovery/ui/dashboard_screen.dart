import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_bloc.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_event.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_state.dart';
import 'package:travel_planner/features/chat/ui/chat_screen.dart';
import 'package:travel_planner/features/profile/ui/profile_screen.dart';
import 'package:travel_planner/features/discovery/ui/destination_details_screen.dart';
import 'package:travel_planner/features/discovery/ui/favorites_screen.dart';
import 'package:travel_planner/features/flights/ui/flight_search_screen.dart';
import 'package:travel_planner/models/destination.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Re-fetch data whenever Dashboard is mounted (e.g. after login)
    context.read<DiscoveryBloc>().add(LoadFeaturedDestinations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DashboardContent(),
          // Floating AI Assistant Button
          Positioned(
            bottom: 30,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              backgroundColor: AppTheme.accentColor,
              icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
              label: const Text(
                'AI Assistant',
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120.0,
          floating: true,
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            title: Text(
              'Explore',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.flight, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FlightSearchScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.person_outline, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Text(
                    'Welcome, ${_getUserFirstName()}',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        context.read<DiscoveryBloc>().add(SearchDestinations(value));
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search destinations...',
                        icon: Icon(Icons.search, color: AppTheme.textSecondary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: const CategoryList(),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: const BudgetFilter(),
                ),
                const SizedBox(height: 32),
                Text(
                  'Popular Destinations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        BlocBuilder<DiscoveryBloc, DiscoveryState>(
          builder: (context, state) {
            if (state is DiscoveryLoading) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
              );
            } else if (state is DiscoveryLoaded) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final destination = state.destinations[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DestinationDetailsScreen(destination: destination),
                              ),
                            );
                          },
                          child: DestinationCard(destination: destination),
                        ),
                      );
                    },
                    childCount: state.destinations.length,
                  ),
                ),
              );
            } else if (state is DiscoveryError) {
              return SliverFillRemaining(
                child: Center(child: Text(state.message)),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox());
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  String _getUserFirstName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    }
    if (user?.email != null) {
      return user!.email!.split('@')[0];
    }
    return 'Traveler';
  }
}

class BudgetFilter extends StatelessWidget {
  const BudgetFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Budget:',
          style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildBudgetChip(context, '\$', true),
                _buildBudgetChip(context, '\$\$', false),
                _buildBudgetChip(context, '\$\$\$', false),
                _buildBudgetChip(context, '\$\$\$\$', false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetChip(BuildContext context, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentColor.withOpacity(0.2) : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.accentColor : Colors.white.withOpacity(0.05),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Beach', 'Mountain', 'Culture', 'Urban', 'History'];
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        final selected = (state is DiscoveryLoaded) ? state.selectedCategory : 'All';
        
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = categories[index] == selected;
              return GestureDetector(
                onTap: () {
                  context.read<DiscoveryBloc>().add(FilterDestinations(categories[index]));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentColor : AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.accentColor : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(destination.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Favorite Button (Top Right)
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                context.read<DiscoveryBloc>().add(ToggleFavorite(destination));
              },
              child: ZoomIn(
                duration: const Duration(milliseconds: 300),
                manualTrigger: true,
                controller: (c) => {}, // Placeholder for local state if needed
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(
                    destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: destination.isFavorite ? Colors.redAccent : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Info Section (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              destination.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              destination.price,
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  destination.location,
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  destination.rating.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
