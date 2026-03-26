import 'package:flutter/material.dart';

import 'calendar_screen/calendar_screen.dart';
import 'statistics_screen/statistics_screen.dart';
import 'widgets_screen/widgets_screen.dart';
import '../widgets/common/bottom_nav_bar.dart';

/// Hosts the three main tabs with a shared bottom navigation bar.
class WeatherHomeShell extends StatefulWidget {
  const WeatherHomeShell({super.key});

  @override
  State<WeatherHomeShell> createState() => _WeatherHomeShellState();
}

class _WeatherHomeShellState extends State<WeatherHomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          CalendarScreen(),
          StatisticsScreen(),
          WidgetsScreen(),
        ],
      ),
      bottomNavigationBar: WeatherBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
