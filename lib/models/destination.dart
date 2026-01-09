import 'package:equatable/equatable.dart';

class Destination extends Equatable {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double rating;
  final String price;
  final String category;
  final bool isFavorite;

  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.price,
    this.category = 'Trending',
    this.isFavorite = false,
  });

  Destination copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    double? rating,
    String? price,
    String? category,
    bool? isFavorite,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'price': price,
      'category': category,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      price: map['price'] ?? '',
      category: map['category'] ?? 'Trending',
    );
  }

  @override
  List<Object?> get props => [id, name, location, description, imageUrl, rating, price, category, isFavorite];
}
