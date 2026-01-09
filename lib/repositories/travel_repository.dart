import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_planner/models/destination.dart';

class TravelRepository {
  final List<Destination> _allDestinations = [
    const Destination(
      id: '1',
      name: 'Santorini',
      location: 'Greece',
      description: 'Breathtaking views of the Aegean Sea with iconic white houses.',
      imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&q=80&w=800',
      rating: 4.9,
      price: '\$1,200',
      category: 'Beach',
    ),
    const Destination(
      id: '2',
      name: 'Kyoto',
      location: 'Japan',
      description: 'Experience the soul of Japan in its historic heart.',
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&q=80&w=800',
      rating: 4.8,
      price: '\$1,500',
      category: 'Culture',
    ),
    const Destination(
      id: '3',
      name: 'Bora Bora',
      location: 'French Polynesia',
      description: 'Crystal clear waters and overwater bungalows.',
      imageUrl: 'https://images.unsplash.com/photo-1532408840957-031d8034aeef?auto=format&fit=crop&q=80&w=800',
      rating: 4.9,
      price: '\$2,400',
      category: 'Beach',
    ),
    const Destination(
      id: '4',
      name: 'Swiss Alps',
      location: 'Switzerland',
      description: 'Majestic mountains and cozy alpine villages.',
      imageUrl: 'https://images.unsplash.com/photo-1531310197839-ccf54634509e?auto=format&fit=crop&q=80&w=800',
      rating: 4.7,
      price: '\$1,800',
      category: 'Mountain',
    ),
    const Destination(
      id: '5',
      name: 'New York City',
      location: 'USA',
      description: 'The city that never sleeps, full of energy and landmarks.',
      imageUrl: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&q=80&w=800',
      rating: 4.6,
      price: '\$2,100',
      category: 'Urban',
    ),
    const Destination(
      id: '6',
      name: 'Machu Picchu',
      location: 'Peru',
      description: 'Ancient Incan citadel set high in the Andes Mountains.',
      imageUrl: 'https://images.unsplash.com/photo-1587590227264-0ac64ce63ce8?auto=format&fit=crop&q=80&w=800',
      rating: 4.9,
      price: '\$1,100',
      category: 'History',
    ),
    const Destination(
      id: '7',
      name: 'Great Barrier Reef',
      location: 'Australia',
      description: 'The world\'s largest coral reef system, visible from space.',
      imageUrl: 'https://images.unsplash.com/photo-1520116468419-a5241b147142?auto=format&fit=crop&q=80&w=800',
      rating: 4.8,
      price: '\$2,200',
      category: 'Beach',
    ),
    const Destination(
      id: '8',
      name: 'Iceland',
      location: 'Reykjavík',
      description: 'Land of Fire and Ice with dramatic landscapes and Northern Lights.',
      imageUrl: 'https://images.unsplash.com/photo-1476610182048-b716b8518aae?auto=format&fit=crop&q=80&w=800',
      rating: 4.9,
      price: '\$1,900',
      category: 'Mountain',
    ),
    const Destination(
      id: '9',
      name: 'Amalfi Coast',
      location: 'Italy',
      description: 'Cliffside villages and turquoise waters along the coast.',
      imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&q=80&w=800',
      rating: 4.8,
      price: '\$1,700',
      category: 'Culture',
    ),
    const Destination(
      id: '10',
      name: 'Sedona',
      location: 'Arizona, USA',
      description: 'Stunning red rock formations and spiritual energy.',
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&q=80&w=800',
      rating: 4.7,
      price: '\$900',
      category: 'History',
    ),
    const Destination(
      id: '11',
      name: 'Tokyo',
      location: 'Japan',
      description: 'A neon-lit metropolis blending tradition and futuristic tech.',
      imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&q=80&w=800',
      rating: 4.9,
      price: '\$1,600',
      category: 'Urban',
    ),
    const Destination(
      id: '12',
      name: 'Banff National Park',
      location: 'Canada',
      description: 'Emerald lakes and rugged mountains in the heart of the Rockies.',
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=800',
      rating: 4.9,
      price: '\$1,400',
      category: 'Mountain',
    ),
  ];

  Future<List<Destination>> getFeaturedDestinations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _allDestinations;
  }

  Future<List<Destination>> searchDestinations(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _allDestinations;
    
    return _allDestinations.where((d) => 
      d.name.toLowerCase().contains(query.toLowerCase()) || 
      d.location.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<List<Destination>> filterByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category == 'All') return _allDestinations;
    
    return _allDestinations.where((d) => d.category == category).toList();
  }

  // --- Firestore Persistence ---

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveFavorite(String uid, Destination destination) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(destination.id)
        .set(destination.toMap());
  }

  Future<void> removeFavorite(String uid, String destinationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(destinationId)
        .delete();
  }

  Future<List<Destination>> fetchFavorites(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();
    
    return snapshot.docs.map((doc) => Destination.fromMap(doc.data())).toList();
  }

  Future<void> saveBooking(String uid, Destination destination) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(destination.id)
        .set(destination.toMap());
  }

  Future<List<Destination>> fetchBookings(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .get();
    
    return snapshot.docs.map((doc) => Destination.fromMap(doc.data())).toList();
  }
}
