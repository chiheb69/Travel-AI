import 'package:equatable/equatable.dart';
import 'package:travel_planner/models/destination.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();
  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}
class DiscoveryLoading extends DiscoveryState {}
class DiscoveryLoaded extends DiscoveryState {
  final List<Destination> destinations;
  final List<Destination> favorites;
  final List<Destination> bookedDestinations;
  final String searchQuery;
  final String selectedCategory;

  const DiscoveryLoaded({
    required this.destinations,
    required this.favorites,
    this.bookedDestinations = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  DiscoveryLoaded copyWith({
    List<Destination>? destinations,
    List<Destination>? favorites,
    List<Destination>? bookedDestinations,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return DiscoveryLoaded(
      destinations: destinations ?? this.destinations,
      favorites: favorites ?? this.favorites,
      bookedDestinations: bookedDestinations ?? this.bookedDestinations,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [destinations, favorites, bookedDestinations, searchQuery, selectedCategory];
}
class DiscoveryError extends DiscoveryState {
  final String message;
  const DiscoveryError({required this.message});
  @override
  List<Object?> get props => [message];
}
