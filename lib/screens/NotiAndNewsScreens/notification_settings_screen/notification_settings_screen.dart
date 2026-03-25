import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
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
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final colorScheme = Theme.of(context).colorScheme;
    final config = provider.config;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.home, color: colorScheme.onSurface),
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
        title: Text(
          AppStrings.tr(languageCode, en: 'Notification Settings', vi: 'Cai dat thong bao'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
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
                  title: AppStrings.tr(languageCode, en: 'Push Notifications', vi: 'Thong bao day'),
                  subtitle: AppStrings.tr(languageCode, en: 'Enable to receive weather updates', vi: 'Bat de nhan cap nhat thoi tiet'),
                  value: config.pushNotificationsEnabled,
                  onChanged: (v) => provider.togglePushNotifications(v),
                ),
              ),
              const SizedBox(height: 20),
              // Daily Forecasts
              _buildSectionTitle(AppStrings.tr(languageCode, en: 'DAILY & HOURLY FORECASTS', vi: 'DU BAO HANG NGAY & THEO GIO')),
              _buildCard(
                child: Column(
                  children: [
                    NotificationToggle(
                      title: AppStrings.tr(languageCode, en: 'Hourly Forecast', vi: 'Du bao theo gio'),
                      subtitle: AppStrings.tr(languageCode, en: 'Receive weather updates each hour', vi: 'Nhan cap nhat moi gio'),
                      value: config.hourlyForecastEnabled,
                      onChanged: (v) => provider.toggleHourlyForecast(v),
                    ),
                    const Divider(height: 24),
                    NotificationToggle(
                      title: AppStrings.tr(languageCode, en: 'Morning Forecast', vi: 'Du bao buoi sang'),
                      subtitle: AppStrings.tr(languageCode, en: 'Daily weather at selected time', vi: 'Du bao hang ngay theo gio da chon'),
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
                      title: AppStrings.tr(languageCode, en: 'Evening Forecast', vi: 'Du bao buoi toi'),
                      subtitle: AppStrings.tr(languageCode, en: 'Daily weather at selected time', vi: 'Du bao hang ngay theo gio da chon'),
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
                      title: AppStrings.tr(languageCode, en: 'Weekend Summary', vi: 'Tong ket cuoi tuan'),
                      subtitle: AppStrings.tr(languageCode, en: 'Friday evening summary for the next days', vi: 'Tong ket toi thu Sau cho nhung ngay toi'),
                      value: config.weekendSummaryEnabled,
                      onChanged: (v) => provider.toggleWeekendSummary(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Weather Alerts
              _buildSectionTitle(AppStrings.tr(languageCode, en: 'WEATHER ALERTS', vi: 'CANH BAO THOI TIET')),
              _buildCard(
                child: Column(
                  children: [
                    NotificationToggle(
                      title: AppStrings.tr(languageCode, en: 'Severe Weather Warnings ⚠️', vi: 'Canh bao thoi tiet khac nghiet ⚠️'),
                      subtitle: AppStrings.tr(languageCode, en: 'Storm, flood, extreme weather', vi: 'Bao, ngap, thoi tiet cuc doan'),
                      warningText: AppStrings.tr(languageCode, en: 'Always recommended ON', vi: 'Khuyen nghi luon bat'),
                      value: config.severeWeatherWarningsEnabled,
                      onChanged: (v) => provider.toggleSevereWeatherWarnings(v),
                      alwaysOn: true,
                    ),
                    const Divider(height: 24),
                    NotificationToggle(
                      title: AppStrings.tr(languageCode, en: 'Weather Advisories 🔔', vi: 'Khuyen cao thoi tiet 🔔'),
                      subtitle: AppStrings.tr(languageCode, en: 'Wind, fog, heat advisories', vi: 'Khuyen cao gio, suong mu, nang nong'),
                      value: config.weatherAdvisoriesEnabled,
                      onChanged: (v) => provider.toggleWeatherAdvisories(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Location-based alerts
              _buildSectionTitle(AppStrings.tr(languageCode, en: 'LOCATION BASED ALERTS', vi: 'CANH BAO THEO VI TRI')),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.tr(languageCode, en: 'Test Notification', vi: 'Thong bao thu'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.tr(languageCode, en: 'This is how weather alerts will appear', vi: 'Canh bao se hien thi nhu vay'),
                                    style: const TextStyle(
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
                      title: AppStrings.tr(languageCode, en: 'Current Location', vi: 'Vi tri hien tai'),
                      subtitle: AppStrings.tr(languageCode, en: 'Uses GPS when app is open', vi: 'Dung GPS khi ung dung duoc mo'),
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
                  label: Text(
                    AppStrings.tr(languageCode, en: 'Send Test Notification', vi: 'Gui thong bao thu'),
                    style: const TextStyle(color: Color(0xFF6B7AEF)),
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
                      SnackBar(
                        content: Text(
                          AppStrings.tr(languageCode, en: 'Scheduled test notification in 5 seconds', vi: 'Da hen gio thong bao thu sau 5 giay'),
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
                  label: Text(
                    AppStrings.tr(languageCode, en: 'Schedule Test Notification (5s)', vi: 'Hen gio thong bao thu (5s)'),
                    style: const TextStyle(color: Color(0xFF6B7AEF)),
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
