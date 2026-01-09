import 'package:equatable/equatable.dart';
import 'package:travel_planner/models/destination.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeaturedDestinations extends DiscoveryEvent {}

class SearchDestinations extends DiscoveryEvent {
  final String query;
  const SearchDestinations(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterDestinations extends DiscoveryEvent {
  final String category;
  const FilterDestinations(this.category);
  @override
  List<Object?> get props => [category];
}

class ToggleFavorite extends DiscoveryEvent {
  final Destination destination;
  const ToggleFavorite(this.destination);
  @override
  List<Object?> get props => [destination];
}

class BookDestination extends DiscoveryEvent {
  final Destination destination;
  const BookDestination(this.destination);
  @override
  List<Object?> get props => [destination];
}

class ClearDiscoveryData extends DiscoveryEvent {}
