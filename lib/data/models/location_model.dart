class LocationModel {
  final String name;
  final double lat;
  final double lon;
  final String country;
  final String? state;
  final int? id; // Thêm ID duy nhất để tránh trùng lặp

  LocationModel({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
    this.state,
    this.id,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      country: json['country'] ?? '',
      state: json['state'],
      id: json['id'] as int?, // ID có thể null nếu API không trả về
    );
  }

  // Phương thức để tạo ID duy nhất dựa trên tọa độ
  String get uniqueId => '$lat,$lon';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.lat == lat &&
        other.lon == lon &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(lat, lon, name);
}
