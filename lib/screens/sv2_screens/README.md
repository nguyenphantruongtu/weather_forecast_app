# SV2 Screens - Weather Forecast App

## Overview
This directory contains the implementation of screens 5-6 from the project requirements:
- **Screen 5**: Home/Current Weather Screen
- **Screen 6**: Hourly Forecast Screen

## Directory Structure

```
lib/
├── screens/sv2_screens/
│   ├── home_screen/
│   │   ├── home_screen.dart          # Main home/current weather screen
│   │   └── widgets/
│   │       ├── current_weather_card.dart      # Displays current weather info
│   │       ├── weather_metrics_grid.dart      # Grid of weather metrics
│   │       └── forecast_preview.dart          # Hourly forecast preview
│   │
│   └── hourly_forecast_screen/
│       ├── hourly_forecast_screen.dart        # Main hourly forecast screen
│       └── widgets/
│           ├── hourly_chart.dart              # Line chart for temperature trend
│           └── hourly_item.dart               # Individual hourly weather item
│
├── data/
│   ├── models/
│   │   ├── weather_model.dart         # Current weather data model
│   │   ├── forecast_model.dart        # Forecast data model
│   │   └── alert_model.dart           # Weather alert model
│   │
│   └── services/
│       └── weather_api_service.dart   # OpenWeatherMap API integration
│
├── providers/
│   └── weather_provider.dart          # Weather data state management
│
└── utils/
    ├── weather_icon_mapper.dart       # Weather icon/emoji mapping
    └── unit_converter.dart            # Unit conversion utilities
```

## Features Implemented

### Screen 5: Home/Current Weather
- **Location Display**: Shows current location (city name)
- **Current Temperature**: Large temperature display with description
- **Feels Like Temperature**: User comfort indicator
- **Weather Metrics Grid**: 6 metrics displayed in a 2x2 grid:
  - Humidity (%)
  - Wind Speed (km/h)
  - Pressure (hPa)
  - Visibility (km)
  - UV Index
  - Dew Point (°C)
- **Hourly Forecast Preview**: Next 4 hours with temperature and condition
- **Search Functionality**: Search for different cities
- **Refresh Button**: Manual data refresh

### Screen 6: Hourly Forecast
- **Temperature Trend Chart**: Line chart showing temperature over next 24 hours
  - Uses `fl_chart` library for visualization
  - Interactive with grid lines and proper scaling
- **Hourly Items List**: Horizontal scrollable list of 48 hourly forecasts
  - Each item shows: time, weather condition, temperature, min/max temp, humidity
  - Selectable items with visual feedback
- **Selected Hour Details**: Detailed view of selected hour including:
  - Time and weather condition
  - Current temperature
  - Humidity, Wind Speed, Cloud Coverage, Precipitation
- **Shimmer Loading**: Professional loading state with shimmer effect

## Technologies Used

1. **State Management**: Provider package
2. **HTTP Client**: Dio for API requests
3. **Charts**: fl_chart for temperature visualization
4. **Date/Time**: intl package for formatting
5. **UI Effects**: shimmer package for loading states
6. **API**: OpenWeatherMap API

## API Integration

The `WeatherApiService` class provides methods for:
- `getCurrentWeather(city)` - Fetch current weather data
- `getHourlyForecast(city)` - Fetch 48-hour forecast
- `getDailyForecast(city)` - Fetch 7-day forecast
- `getWeatherByCoordinates(lat, lon)` - Fetch weather by coordinates

**Note**: Replace `YOUR_API_KEY_HERE` in `weather_api_service.dart` with your OpenWeatherMap API key.

## Models

### WeatherModel
Contains current weather data:
- Location, temperature, description, icon
- Feels like, humidity, wind speed, pressure
- Visibility, UV index, dew point
- Sunrise/sunset times, last updated

### ForecastModel
Contains forecast data for a specific time:
- Time (dt_txt format)
- Temperature (current, min, max, feels like)
- Humidity, wind speed, description, icon
- Precipitation chance, cloudiness

### AlertModel
Contains weather alert information:
- Event type, description
- Start and end times

## Provider State

The `WeatherProvider` manages:
- Current weather data
- Hourly forecast list
- Daily forecast list
- Loading state
- Error messages

Methods:
- `fetchCurrentWeather(city)` - Load current weather
- `fetchHourlyForecast(city)` - Load hourly forecast
- `fetchDailyForecast(city)` - Load daily forecast
- `fetchWeatherByCoordinates(lat, lon)` - Load weather by location
- `clearData()` - Clear cached data

## Routing

The application includes named routes:
- `/home` - Home/Current Weather screen
- `/hourly-forecast` - Hourly Forecast screen

## Error Handling

- Try-catch blocks in all API calls
- User-friendly error messages displayed in UI
- Retry button in error state
- Loading shimmer for better UX

## Future Enhancements

- [ ] Daily forecast screen (Screen 7)
- [ ] Weather details screen (Screen 8)
- [ ] Settings screen for unit preferences (°C/°F)
- [ ] Location-based weather with GPS
- [ ] Weather alerts and notifications
- [ ] Offline data caching
- [ ] Dark mode support
- [ ] Multi-language support

## Notes

- All temperature values are in Celsius by default
- Wind speeds are in km/h
- Pressure is in hPa
- Visibility is in kilometers
- The app uses Material Design 3 design system
