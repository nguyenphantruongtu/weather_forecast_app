class Location {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;

  Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
  });

  // Factory constructor to create a Location from a map
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      country: map['country'] ?? '',
    );
  }

  // Method to convert Location to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
    };
  }

  @override
  String toString() {
    return 'Location{id: $id, name: $name, latitude: $latitude, longitude: $longitude, country: $country}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Location &&
           other.id == id &&
           other.name == name &&
           other.latitude == latitude &&
           other.longitude == longitude &&
           other.country == country;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ latitude.hashCode ^ longitude.hashCode ^ country.hashCode;
  }
}