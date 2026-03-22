# Screen 7 & 8 Integration Guide

This guide provides step-by-step instructions for integrating the new Daily Forecast (Screen 7) and Weather Details (Screen 8) screens into your application.

## Quick Start

### 1. Import the Screens

```dart
// In your main navigation file
import 'package:final_project/screens/sv2_screens/daily_forecast_screen/daily_forecast_screen.dart';
import 'package:final_project/screens/sv2_screens/weather_details_screen/weather_details_screen.dart';
```

### 2. Add Navigation Routes

```dart
import 'package:flutter/material.dart';
import 'package:final_project/screens/sv2_screens/daily_forecast_screen/daily_forecast_screen.dart';
import 'package:final_project/screens/sv2_screens/weather_details_screen/weather_details_screen.dart';

class NavigationHelper {
  static Future<void> navigateToDailyForecast(
    BuildContext context, {
    String? city,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyForecastScreen(city: city),
      ),
    );
  }

  static Future<void> navigateToWeatherDetails(
    BuildContext context, {
    String? city,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailsScreen(city: city),
      ),
    );
  }
}
```

### 3. Update Your Bottom Navigation or Menu

#### Option A: Bottom Navigation Bar

```dart
class MainScreens extends StatefulWidget {
  @override
  State<MainScreens> createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),             // Screen 5
    const HourlyForecastScreen(),   // Screen 6
    const DailyForecastScreen(),    // Screen 7 - NEW
    const WeatherDetailsScreen(),   // Screen 8 - NEW
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Hourly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Details',
          ),
        ],
      ),
    );
  }
}
```

#### Option B: Drawer Navigation

```dart
FloatingActionButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildWeatherMenu(context),
    );
  },
  child: const Icon(Icons.cloud),
)

Widget _buildWeatherMenu(BuildContext context) {
  return Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Hourly Forecast'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HourlyForecastScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month),
          title: const Text('Daily Forecast (7-10 days)'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyForecastScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Weather Details'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeatherDetailsScreen()),
            );
          },
        ),
      ],
    ),
  );
}
```

#### Option C: Named Routes (Recommended)

```dart
// In your main.dart or routes.dart
class AppRoutes {
  static const String home = '/home';
  static const String hourlyForecast = '/hourly-forecast';
  static const String dailyForecast = '/daily-forecast';
  static const String weatherDetails = '/weather-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case hourlyForecast:
        return MaterialPageRoute(builder: (_) => const HourlyForecastScreen());
      case dailyForecast:
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => DailyForecastScreen(city: args),
        );
      case weatherDetails:
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => WeatherDetailsScreen(city: args),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

// In MyApp widget
MaterialApp(
  // ... other properties
  onGenerateRoute: AppRoutes.generateRoute,
  initialRoute: AppRoutes.home,
)

// Usage
Navigator.pushNamed(
  context,
  AppRoutes.dailyForecast,
  arguments: 'Tokyo',
);
```

## Adding Search/Quick Access Buttons

### Add to Home Screen

```dart
// In home_screen.dart, add quick access buttons

class QuickAccessButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyForecastScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('7-10 Day'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeatherDetailsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.info),
              label: const Text('Details'),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Passing City Data Between Screens

### Method 1: Constructor Parameters

```dart
// Recommended for simple data passing

// From any screen:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DailyForecastScreen(
      city: 'Bangkok',
    ),
  ),
);
```

### Method 2: Provider (Recommended for app-wide state)

```dart
// In your provider
class CityProvider extends ChangeNotifier {
  String _selectedCity = 'Hanoi';
  
  String get selectedCity => _selectedCity;
  
  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }
}

// Usage in screens
final city = context.watch<CityProvider>().selectedCity;
```

### Method 3: Named Route Arguments

```dart
Navigator.pushNamed(
  context,
  '/daily-forecast',
  arguments: 'Paris',
);
```

## Screen Interaction Patterns

### Scenario 1: User searching for weather

```
HomeScreen (search for city)
    ↓
Fetch weather for that city
    ↓
Display current weather
    ↓ (User taps "7-10 day forecast" button)
DailyForecastScreen (same city)
    ↓ OR (User taps "Details" button)
WeatherDetailsScreen (same city)
```

### Scenario 2: User comparing daily vs hourly

```
DailyForecastScreen
    ↓ (User taps on a specific day)
Could navigate to HourlyForecastScreen for that day
(Feature enhancement for future)
```

## Testing the Screens

### Quick Test in main.dart

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast App',
      theme: ThemeData(useMaterial3: true),
      home: const DailyForecastScreen(city: 'Hanoi'),
      // or
      // home: const WeatherDetailsScreen(city: 'Hanoi'),
    );
  }
}
```

## Troubleshooting Common Issues

### Issue: "Provider not found"
**Solution**: Ensure WeatherProvider is wrapped in your widget tree
```dart
main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => WeatherProvider()),
      // other providers
    ],
    child: const MyApp(),
  ),
);
```

### Issue: "City parameter not being used"
**Solution**: Ensure `fetchCurrentWeather()` or `fetchDailyForecast()` is called with the city

### Issue: "Charts not displaying"
**Solution**: Check that:
1. Data is not empty
2. `fl_chart` package is imported
3. Values are valid numbers (no NaN or Infinity)

### Issue: "Screens not updating on back navigation"
**Solution**: Override `didChangeDependencies()` or use `Provider` watched values

## Performance Tips

1. **Lazy Load Data**: Don't fetch data until screen is opened
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}
```

2. **Avoid Rebuilds**: Use `Consumer` instead of `Watch`
```dart
Consumer<WeatherProvider>(
  builder: (context, provider, _) {
    // Only rebuild when provider changes
  },
)
```

3. **Dispose Resources**: Always clean up listeners
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

## Accessibility Considerations

- Add tooltip labels to icon buttons
- Use semantic labels for charts
- Ensure text contrast meets WCAG standards
- Support text scaling

Example:
```dart
IconButton(
  onPressed: _loadData,
  tooltip: 'Refresh weather data',
  icon: const Icon(Icons.refresh),
)
```

---

**Last Updated**: March 22, 2026
