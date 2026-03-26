/// OpenWeather `units=metric` returns wind in m/s; UI often shows km/h.
class TemperatureUtils {
  TemperatureUtils._();

  static double windMsToKmh(double metersPerSecond) => metersPerSecond * 3.6;
}
