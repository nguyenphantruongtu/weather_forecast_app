import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/notification_provider.dart';
import 'widgets/notification_toggle.dart';
import 'widgets/time_picker_tile.dart';
import '../../../../screens/main_wrapper_screen.dart';
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _showTestNotif = false;

  final List<String> _availableLocations = [
    'Hanoi',
    'Ho Chi Minh City',
    'Da Nang',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final config = provider.config;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Color(0xFF1A1A2E)),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainWrapperScreen(),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Master toggle card
              _buildCard(
                child: NotificationToggle(
                  title: 'Push Notifications',
                  subtitle: 'Enable to receive weather updates',
                  value: config.pushNotificationsEnabled,
                  onChanged: (v) => provider.togglePushNotifications(v),
                ),
              ),
              const SizedBox(height: 20),
              // Daily Forecasts
              _buildSectionTitle('DAILY & HOURLY FORECASTS'),
              _buildCard(
                child: Column(
                  children: [
                    NotificationToggle(
                      title: 'Hourly Forecast',
                      subtitle: 'Receive weather updates each hour',
                      value: config.hourlyForecastEnabled,
                      onChanged: (v) => provider.toggleHourlyForecast(v),
                    ),
                    const Divider(height: 24),
                    NotificationToggle(
                      title: 'Morning Forecast',
                      subtitle: 'Daily weather at selected time',
                      value: config.morningForecastEnabled,
                      onChanged: (v) => provider.toggleMorningForecast(v),
                    ),
                    if (config.morningForecastEnabled) ...[
                      const SizedBox(height: 4),
                      TimePickerTile(
                        time: config.morningForecastTime,
                        onTimeChanged: (t) => provider.updateForecastTime(
                          isMorning: true,
                          newTime: t,
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    NotificationToggle(
                      title: 'Evening Forecast',
                      subtitle: 'Daily weather at selected time',
                      value: config.eveningForecastEnabled,
                      onChanged: (v) => provider.toggleEveningForecast(v),
                    ),
                    if (config.eveningForecastEnabled) ...[
                      const SizedBox(height: 4),
                      TimePickerTile(
                        time: config.eveningForecastTime,
                        onTimeChanged: (t) => provider.updateForecastTime(
                          isMorning: false,
                          newTime: t,
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    NotificationToggle(
                      title: 'Weekend Summary',
                      subtitle: 'Friday evening summary for the next days',
                      value: config.weekendSummaryEnabled,
                      onChanged: (v) => provider.toggleWeekendSummary(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Weather Alerts
              _buildSectionTitle('WEATHER ALERTS'),
              _buildCard(
                child: Column(
                  children: [
                    NotificationToggle(
                      title: 'Severe Weather Warnings ⚠️',
                      subtitle: 'Storm, flood, extreme weather',
                      warningText: 'Always recommended ON',
                      value: config.severeWeatherWarningsEnabled,
                      onChanged: (v) => provider.toggleSevereWeatherWarnings(v),
                      alwaysOn: true,
                    ),
                    const Divider(height: 24),
                    NotificationToggle(
                      title: 'Weather Advisories 🔔',
                      subtitle: 'Wind, fog, heat advisories',
                      value: config.weatherAdvisoriesEnabled,
                      onChanged: (v) => provider.toggleWeatherAdvisories(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Location-based alerts
              _buildSectionTitle('LOCATION BASED ALERTS'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Test notification preview
                    if (_showTestNotif)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF6B7AEF).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF6B7AEF),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Test Notification',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'This is how weather alerts will appear',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showTestNotif = false),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Location checkboxes
                    ..._availableLocations.map(
                      (loc) => _buildLocationCheckbox(loc, provider),
                    ),
                    const Divider(height: 20),
                    // Current location toggle
                    NotificationToggle(
                      title: 'Current Location',
                      subtitle: 'Uses GPS when app is open',
                      value: config.useCurrentLocation,
                      onChanged: (v) => provider.toggleCurrentLocation(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Test notification button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.sendTestNotification();
                    setState(() => _showTestNotif = true);
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: Color(0xFF6B7AEF),
                  ),
                  label: const Text(
                    'Send Test Notification',
                    style: TextStyle(color: Color(0xFF6B7AEF)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B7AEF)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await provider.scheduleTestNotification(seconds: 5);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Scheduled test notification in 5 seconds',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    setState(() => _showTestNotif = true);
                  },
                  icon: const Icon(
                    Icons.schedule,
                    size: 18,
                    color: Color(0xFF6B7AEF),
                  ),
                  label: const Text(
                    'Schedule Test Notification (5s)',
                    style: TextStyle(color: Color(0xFF6B7AEF)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B7AEF)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCheckbox(
    String location,
    NotificationProvider provider,
  ) {
    final isSelected = provider.config.subscribedLocations.contains(location);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              provider.toggleLocation(location, !isSelected);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B7AEF)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6B7AEF) : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            location,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
