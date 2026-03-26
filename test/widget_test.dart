// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/app.dart';
import 'package:provider/provider.dart';
import 'package:final_project/providers/settings_provider.dart';
import 'package:final_project/providers/news_provider.dart';
import 'package:final_project/providers/weather_provider.dart';
import 'package:final_project/providers/notification_provider.dart';
import 'package:final_project/providers/location_provider.dart';

void main() {
  testWidgets('App launches with SplashScreen', (WidgetTester tester) async {
    final settingsProvider = SettingsProvider();

    // Build app with providers similar to production bootstrap.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: settingsProvider,
          ),
          ChangeNotifierProvider(create: (_) => NewsProvider()),
          ChangeNotifierProvider(create: (_) => WeatherProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Allow SplashScreen delayed timer to fire in test environment.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    
    // Verify that the app has rendered (no errors)
    expect(find.byType(MyApp), findsOneWidget);
  });
}
