/// Maps OpenWeather `main` condition strings to emoji (aligned with [WeatherDay]).
class WeatherIconMapper {
  WeatherIconMapper._();

  static String emojiForMain(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '🌨️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '☀️';
    }
  }
}
