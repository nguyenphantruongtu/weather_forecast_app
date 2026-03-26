class AppStrings {
  static bool isVietnamese(String languageCode) {
    return languageCode.toLowerCase().startsWith('vi');
  }

  static String intlLocale(String languageCode) {
    return isVietnamese(languageCode) ? 'vi_VN' : 'en_US';
  }

  static String tr(
    String languageCode, {
    required String en,
    required String vi,
  }) {
    return isVietnamese(languageCode) ? vi : en;
  }

  static String weatherDescription(String languageCode, String source) {
    final normalized = source.trim().toLowerCase();
    if (normalized.isEmpty) return source;

    final map = <String, Map<String, String>>{
      'clear': {'en': 'Clear', 'vi': 'Trời quang'},
      'clouds': {'en': 'Cloudy', 'vi': 'Nhiều mây'},
      'overcast': {'en': 'Overcast', 'vi': 'U ám'},
      'rain': {'en': 'Rain', 'vi': 'Mưa'},
      'drizzle': {'en': 'Drizzle', 'vi': 'Mưa phùn'},
      'thunderstorm': {'en': 'Thunderstorm', 'vi': 'Giông sét'},
      'snow': {'en': 'Snow', 'vi': 'Tuyết'},
      'mist': {'en': 'Mist', 'vi': 'Sương nhẹ'},
      'fog': {'en': 'Fog', 'vi': 'Sương mù'},
      'haze': {'en': 'Haze', 'vi': 'Mù mờ'},
      'smoke': {'en': 'Smoke', 'vi': 'Khói'},
      'dust': {'en': 'Dust', 'vi': 'Bụi'},
      'sand': {'en': 'Sand', 'vi': 'Cát'},
      'ash': {'en': 'Ash', 'vi': 'Tro'},
      'squall': {'en': 'Squall', 'vi': 'Gió giật'},
      'tornado': {'en': 'Tornado', 'vi': 'Lốc xoáy'},
    };

    for (final key in map.keys) {
      if (normalized.contains(key)) {
        final pair = map[key]!;
        return isVietnamese(languageCode) ? pair['vi']! : pair['en']!;
      }
    }

    return source;
  }
}
