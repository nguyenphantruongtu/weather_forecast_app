import 'package:flutter/foundation.dart';

class Location {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? state;
  final bool isFavorite;

  Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.state,
    this.isFavorite = false,
  });

  Location copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? state,
    bool? isFavorite,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      state: state ?? this.state,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'state': state,
      'isFavorite': isFavorite,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      country: map['country'] ?? '',
      state: map['state'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Location(id: $id, name: $name, latitude: $latitude, longitude: $longitude, country: $country, state: $state, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Location &&
      other.id == id &&
      other.name == name &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.country == country &&
      other.state == state &&
      other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      country.hashCode ^
      state.hashCode ^
      isFavorite.hashCode;
  }
}

class LocationSearchResult {
  final List<Location> locations;
  final List<String> recentSearches;

  LocationSearchResult({
    required this.locations,
    required this.recentSearches,
  });
}