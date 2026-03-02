class LocationModel {
  final String name;
  final double lat;
  final double lon;
  final String country;
  final String? state;

  LocationModel({required this.name, required this.lat, required this.lon, required this.country, this.state});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      country: json['country'] ?? '',
      state: json['state'],
    );
  }
}