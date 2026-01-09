import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_event.dart';
import 'package:travel_planner/features/discovery/bloc/discovery_state.dart';
import 'package:travel_planner/repositories/travel_repository.dart';
import 'package:travel_planner/models/destination.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final TravelRepository _travelRepository;
  final List<Destination> _favorites = [];
  final List<Destination> _bookedDestinations = [];

  DiscoveryBloc({required TravelRepository travelRepository})
      : _travelRepository = travelRepository,
        super(DiscoveryInitial()) {
    on<LoadFeaturedDestinations>(_onLoadFeaturedDestinations);
    on<SearchDestinations>(_onSearchDestinations);
    on<FilterDestinations>(_onFilterDestinations);
    on<ToggleFavorite>(_onToggleFavorite);
    on<BookDestination>(_onBookDestination);
    on<ClearDiscoveryData>(_onClearDiscoveryData);
  }

  Future<void> _onLoadFeaturedDestinations(
    LoadFeaturedDestinations event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoveryLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final favorites = await _travelRepository.fetchFavorites(user.uid);
          final bookings = await _travelRepository.fetchBookings(user.uid);
          _favorites.clear();
          _favorites.addAll(favorites);
          _bookedDestinations.clear();
          _bookedDestinations.addAll(bookings);
        } catch (e) {
          debugPrint("Firestore fetch failed (likely rules): $e");
          // Continue loading static data even if cloud fetch fails
        }
      }

      final destinations = await _travelRepository.getFeaturedDestinations();
      emit(DiscoveryLoaded(
        destinations: _syncFavorites(destinations),
        favorites: List.from(_favorites),
        bookedDestinations: List.from(_bookedDestinations),
      ));
    } catch (e) {
      emit(DiscoveryError(message: e.toString()));
    }
  }

  Future<void> _onSearchDestinations(
    SearchDestinations event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final current = state as DiscoveryLoaded;
      try {
        final results = await _travelRepository.searchDestinations(event.query);
        emit(current.copyWith(
          destinations: _syncFavorites(results),
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(DiscoveryError(message: e.toString()));
      }
    }
  }

  Future<void> _onFilterDestinations(
    FilterDestinations event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final current = state as DiscoveryLoaded;
      try {
        final results = await _travelRepository.filterByCategory(event.category);
        emit(current.copyWith(
          destinations: _syncFavorites(results),
          selectedCategory: event.category,
        ));
      } catch (e) {
        emit(DiscoveryError(message: e.toString()));
      }
    }
  }

  void _onToggleFavorite(
    ToggleFavorite event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final current = state as DiscoveryLoaded;
      final user = FirebaseAuth.instance.currentUser;
      
      final isFav = _favorites.any((d) => d.id == event.destination.id);
      if (isFav) {
        _favorites.removeWhere((d) => d.id == event.destination.id);
        if (user != null) {
          await _travelRepository.removeFavorite(user.uid, event.destination.id);
        }
      } else {
        final favDestination = event.destination.copyWith(isFavorite: true);
        _favorites.add(favDestination);
        if (user != null) {
          await _travelRepository.saveFavorite(user.uid, favDestination);
        }
      }

      emit(current.copyWith(
        destinations: _syncFavorites(current.destinations),
        favorites: List.from(_favorites),
      ));
    }
  }

  void _onBookDestination(
    BookDestination event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final current = state as DiscoveryLoaded;
      final user = FirebaseAuth.instance.currentUser;
      
      final isBooked = _bookedDestinations.any((d) => d.id == event.destination.id);
      if (!isBooked) {
        _bookedDestinations.add(event.destination);
        if (user != null) {
          await _travelRepository.saveBooking(user.uid, event.destination);
        }
        emit(current.copyWith(
          bookedDestinations: List.from(_bookedDestinations),
        ));
      }
    }
  }

  void _onClearDiscoveryData(
    ClearDiscoveryData event,
    Emitter<DiscoveryState> emit,
  ) {
    _favorites.clear();
    _bookedDestinations.clear();
    if (state is DiscoveryLoaded) {
      final current = state as DiscoveryLoaded;
      emit(current.copyWith(
        favorites: [],
        bookedDestinations: [],
        destinations: current.destinations.map((d) => d.copyWith(isFavorite: false)).toList(),
      ));
    }
  }

  List<Destination> _syncFavorites(List<Destination> destinations) {
    return destinations.map((d) {
      final isFav = _favorites.any((fav) => fav.id == d.id);
      return d.copyWith(isFavorite: isFav);
    }).toList();
  }
}
