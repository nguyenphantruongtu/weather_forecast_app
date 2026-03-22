import 'package:flutter/material.dart';
import '../../../../data/models/notification_config_model.dart';
import 'widgets/notification_toggle.dart';
import 'widgets/time_picker_tile.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationConfigModel _config;
  bool _showTestNotif = false;

  final List<String> _availableLocations = ['Hanoi', 'Ho Chi Minh City', 'Da Nang'];

  @override
  void initState() {
    super.initState();
    _config = NotificationConfigModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
                  value: _config.pushNotificationsEnabled,
                  onChanged: (v) =>
                      setState(() => _config.pushNotificationsEnabled = v),
                ),
              ),
              const SizedBox(height: 20),
              // Daily Forecasts
              _buildSectionTitle('DAILY FORECASTS'),
              _buildCard(
                child: Column(
                  children: [
                    NotificationToggle(
                      title: 'Morning Forecast',
                      subtitle: 'Daily weather at 7:00 AM',
                      value: _config.morningForecastEnabled,
                      onChanged: (v) =>
                          setState(() => _config.morningForecastEnabled = v),
                    ),
                    if (_config.morningForecastEnabled) ...[
                      const SizedBox(height: 4),
                      TimePickerTile(
                        time: _config.morningForecastTime,
                        onTimeChanged: (t) =>
                            setState(() => _config.morningForecastTime = t),
                      ),
                    ],
                    const Divider(height: 24),
                    NotificationToggle(
                      title: 'Evening Forecast',
                      subtitle: 'Daily weather at 7:00 PM',
                      value: _config.eveningForecastEnabled,
                      onChanged: (v) =>
                          setState(() => _config.eveningForecastEnabled = v),
                    ),
                    if (_config.eveningForecastEnabled) ...[
                      const SizedBox(height: 4),
                      TimePickerTile(
                        time: _config.eveningForecastTime,
                        onTimeChanged: (t) =>
                            setState(() => _config.eveningForecastTime = t),
                      ),
                    ],
                    const Divider(height: 24),
                    NotificationToggle(
                      title: 'Weekend Summary',
                      subtitle: 'Friday evening forecast for weekend',
                      value: _config.weekendSummaryEnabled,
                      onChanged: (v) =>
                          setState(() => _config.weekendSummaryEnabled = v),
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
                      value: _config.severeWeatherWarningsEnabled,
                      onChanged: (v) => setState(
                          () => _config.severeWeatherWarningsEnabled = v),
                      alwaysOn: true,
                    ),
                    const Divider(height: 24),
                    NotificationToggle(
                      title: 'Weather Advisories 🔔',
                      subtitle: 'Wind, fog, heat advisories',
                      value: _config.weatherAdvisoriesEnabled,
                      onChanged: (v) =>
                          setState(() => _config.weatherAdvisoriesEnabled = v),
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
                          border: Border.all(color: const Color(0xFF6B7AEF).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_outlined,
                                color: Color(0xFF6B7AEF), size: 24),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Test Notification',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  Text(
                                      'This is how weather alerts will appear',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showTestNotif = false),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    // Location checkboxes
                    ..._availableLocations.map((loc) => _buildLocationCheckbox(loc)),
                    const Divider(height: 20),
                    // Current location toggle
                    NotificationToggle(
                      title: 'Current Location',
                      subtitle: 'Uses GPS when app is open',
                      value: _config.useCurrentLocation,
                      onChanged: (v) =>
                          setState(() => _config.useCurrentLocation = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Test notification button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showTestNotif = true),
                  icon: const Icon(Icons.notifications_outlined,
                      size: 18, color: Color(0xFF6B7AEF)),
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
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCheckbox(String location) {
    final isSelected = _config.subscribedLocations.contains(location);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _config.subscribedLocations.remove(location);
                } else {
                  _config.subscribedLocations.add(location);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6B7AEF) : Colors.transparent,
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