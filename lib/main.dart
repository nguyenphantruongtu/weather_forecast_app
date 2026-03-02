import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/location_provider.dart';
import 'features/location_search_screen/location_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load file .env trước khi chạy App
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App Group 6',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: LocationSearchScreen(), // Màn hình của Tùng
    );
  }
}