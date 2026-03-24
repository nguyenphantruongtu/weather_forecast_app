class LocationChoice {
  final String city;
  final String country;
  final int temperature;
  final String condition;
  final String emoji;
  final double latitude;
  final double longitude;
  final String region;

  const LocationChoice({
    required this.city,
    required this.country,
    this.temperature = 72,
    this.condition = 'Partly Cloudy',
    this.emoji = '⛅',
    this.latitude = 0,
    this.longitude = 0,
    this.region = 'All',
  });

  String get fullName => '$city, $country';
}
