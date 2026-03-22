# Code Examples & Best Practices

## Daily Forecast Screen Examples

### Basic Usage

```dart
import 'package:final_project/screens/sv2_screens/daily_forecast_screen/daily_forecast_screen.dart';

// Simple navigation
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyForecastScreen(city: 'Hanoi'),
      ),
    );
  },
  child: const Text('View 7-10 Day Forecast'),
)
```

### With Dynamic City Selection

```dart
class WeatherHomeScreen extends StatefulWidget {
  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  String _selectedCity = 'Hanoi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Column(
        children: [
          // City selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: _selectedCity,
              items: ['Hanoi', 'Ho Chi Minh', 'Da Nang', 'Bangkok', 'Tokyo']
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
              onChanged: (newCity) {
                setState(() => _selectedCity = newCity!);
              },
            ),
          ),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DailyForecastScreen(
                        city: _selectedCity,
                      ),
                    ),
                  );
                },
                child: const Text('Daily Forecast'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeatherDetailsScreen(
                        city: _selectedCity,
                      ),
                    ),
                  );
                },
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Weather Details Screen Examples

### Accessing Provider Data

```dart
// In your widget
@override
Widget build(BuildContext context) {
  return Consumer<WeatherProvider>(
    builder: (context, weatherProvider, _) {
      // Access data safely
      if (weatherProvider.currentWeather == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final weather = weatherProvider.currentWeather!;
      
      return Column(
        children: [
          Text('Temperature: ${weather.temperature}°C'),
          Text('Humidity: ${weather.humidity}%'),
          Text('Wind: ${weather.windSpeed} m/s'),
          Text('UV Index: ${weather.uvIndex}'),
        ],
      );
    },
  );
}
```

### Custom Widget Using Weather Details

```dart
class WeatherSummaryWidget extends StatelessWidget {
  final WeatherModel weather;

  const WeatherSummaryWidget({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              weather.location,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${weather.temperature.toStringAsFixed(1)}° - ${weather.description}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  icon: Icons.opacity,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
                _DetailItem(
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${weather.windSpeed} m/s',
                ),
                _DetailItem(
                  icon: Icons.sunny,
                  label: 'UV Index',
                  value: weather.uvIndex.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
```

## Data Caching Pattern

```dart
class CachedWeatherProvider extends WeatherProvider {
  late Future<WeatherModel?> _cachedCurrentWeather;
  late Future<List<ForecastModel>> _cachedDailyForecast;
  DateTime? _lastFetchTime;
  
  final Duration _cacheDuration = const Duration(hours: 1);

  @override
  Future<void> fetchCurrentWeather(String city) async {
    // Check if cache is still valid
    if (_lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return; // Use cached data
    }
    
    // Fetch new data
    await super.fetchCurrentWeather(city);
    _lastFetchTime = DateTime.now();
  }

  bool isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
}
```

## Error Handling Best Practices

```dart
class RobustWeatherScreen extends StatefulWidget {
  @override
  State<RobustWeatherScreen> createState() => _RobustWeatherScreenState();
}

class _RobustWeatherScreenState extends State<RobustWeatherScreen> {
  String? _errorMessage;
  bool _isRetrying = false;

  Future<void> _handleWeatherFetch() async {
    try {
      setState(() => _isRetrying = true);
      await context.read<WeatherProvider>().fetchCurrentWeather('Hanoi');
      setState(() => _errorMessage = null);
    } on SocketException {
      setState(() => _errorMessage = 'No internet connection');
    } on TimeoutException {
      setState(() => _errorMessage = 'Request timed out');
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: _errorMessage != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isRetrying ? null : _handleWeatherFetch,
                  child: const Text('Retry'),
                ),
              ],
            )
          : const WeatherDetailsScreen(),
    );
  }
}
```

##Testing Examples

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:final_project/screens/sv2_screens/daily_forecast_screen/daily_forecast_screen.dart';

void main() {
  group('DailyForecastScreen Tests', () {
    late MockWeatherProvider mockWeatherProvider;

    setUp(() {
      mockWeatherProvider = MockWeatherProvider();
    });

    testWidgets('Screen loads with forecasts', (WidgetTester tester) async {
      when(mockWeatherProvider.dailyForecast).thenReturn([
        ForecastModel(
          dt: '2026-03-22 12:00:00',
          temp: 28,
          tempMin: 25,
          tempMax: 31,
          feelsLike: 29,
          humidity: 65,
          windSpeed: 3.5,
          description: 'Clear',
          icon: '01d',
          precipitation: 0,
          cloudiness: 10,
        ),
      ]);
      when(mockWeatherProvider.isLoading).thenReturn(false);
      when(mockWeatherProvider.error).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>.value(
            value: mockWeatherProvider,
            child: const DailyForecastScreen(),
          ),
        ),
      );

      expect(find.text('Daily Forecast'), findsWidgets);
      expect(find.byType(DailyForecastCard), findsWidgets);
    });

    testWidgets('Error handling works', (WidgetTester tester) async {
      when(mockWeatherProvider.isLoading).thenReturn(false);
      when(mockWeatherProvider.error).thenReturn('Network error');
      when(mockWeatherProvider.dailyForecast).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>.value(
            value: mockWeatherProvider,
            child: const DailyForecastScreen(),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsWidgets); // Retry button
    });
  });
}
```

## Performance Optimization Patterns

```dart
class OptimizedWeatherScreen extends StatefulWidget {
  final String city;

  const OptimizedWeatherScreen({required this.city});

  @override
  State<OptimizedWeatherScreen> createState() => 
      _OptimizedWeatherScreenState();
}

class _OptimizedWeatherScreenState extends State<OptimizedWeatherScreen> {
  final _debounceTimer = _debounceSearch;
  
  @override
  void initState() {
    super.initState();
    // Defer loading to avoid jank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherData();
    });
  }

  void _loadWeatherData() {
    // Only load if widget is still mounted
    if (mounted) {
      context.read<WeatherProvider>()
          .fetchCurrentWeather(widget.city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Use SingleChildScrollView instead of ListView for better performance
        // with limited number of children
        child: Consumer<WeatherProvider>(
          // Only rebuild affected widgets
          builder: (context, provider, child) {
            return Column(
              children: [
                if (provider.isLoading)
                  const CircularProgressIndicator()
                else if (provider.currentWeather != null)
                  WeatherDetailsCard(weather: provider.currentWeather!)
                else
                  const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    super.dispose();
  }
}

// Debounce helper for search
class _DebounceTimer {
  Timer? _timer;

  void call(VoidCallback callback, {Duration duration = const Duration(milliseconds: 500)}) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void cancel() => _timer?.cancel();
}

_DebounceTimer get _debounceSearch => _DebounceTimer();
```

## Chart Customization

```dart
// Custom chart styling for DailyForecastChart
class CustomColoredChart extends DailyForecastChart {
  const CustomColoredChart({required super.forecasts});

  @override
  Widget build(BuildContext context) {
    // You can extend the parent class and override the chart colors
    return super.build(context);
  }
}

// Alternative: Create your own chart variant
class TemperatureRangeChart extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const TemperatureRangeChart({required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: forecasts
                    .asMap()
                    .entries
                    .map((e) => FlSpot(
                          e.key.toDouble(),
                          e.value.tempMax,
                        ))
                    .toList(),
                color: Colors.red,
                label: 'Max Temp',
              ),
              LineChartBarData(
                spots: forecasts
                    .asMap()
                    .entries
                    .map((e) => FlSpot(
                          e.key.toDouble(),
                          e.value.tempMin,
                        ))
                    .toList(),
                color: Colors.blue,
                label: 'Min Temp',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

**Last Updated**: March 22, 2026
