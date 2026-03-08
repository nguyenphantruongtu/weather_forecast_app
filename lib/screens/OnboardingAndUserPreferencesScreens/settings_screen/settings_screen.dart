import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/models/settings_model.dart';
import '../info_screen/info_screen.dart';
import 'widgets/setting_tile.dart';

/// Màn hình Cài đặt (Màn 3 - Settings & Preferences)
/// Cho phép người dùng tùy chỉnh nhiệt độ, theme, định dạng giờ, ngôn ngữ
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // context.watch: theo dõi provider, rebuild khi provider thay đổi
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === SECTION: Units ===
            _buildSectionHeader(context, 'Units'),
            SettingTile(
              title: 'Temperature Unit',
              subtitle: settings.temperatureUnit == TemperatureUnit.celsius
                  ? 'Celsius (°C)'
                  : 'Fahrenheit (°F)',
              icon: Icons.thermostat,
              onTap: () => _showTemperatureUnitSelector(context),
            ),
            SettingTile(
              title: 'Wind Speed Unit',
              subtitle: settings.windSpeedUnit == WindSpeedUnit.kmh
                  ? 'Kilometers per hour (km/h)'
                  : 'Miles per hour (mph)',
              icon: Icons.air,
              onTap: () => _showWindSpeedUnitSelector(context),
            ),
            const Divider(),

            // === SECTION: Display ===
            _buildSectionHeader(context, 'Display'),
            ToggleSettingTile(
              title: 'Dark Mode',
              subtitle: settings.theme == AppTheme.dark ? 'Enabled' : 'Disabled',
              icon: Icons.dark_mode,
              value: settings.theme == AppTheme.dark,
              onChanged: (value) {
                // onChanged: callback khi toggle thay đổi
                settingsProvider.updateTheme(
                  value ? AppTheme.dark : AppTheme.light,
                );
              },
            ),
            SettingTile(
              title: 'Time Format',
              subtitle: settings.timeFormat == TimeFormat.h24 ? '24-hour' : '12-hour',
              icon: Icons.schedule,
              onTap: () => _showTimeFormatSelector(context),
            ),
            const Divider(),

            // === SECTION: Localization ===
            _buildSectionHeader(context, 'Localization'),
            SettingTile(
              title: 'Language',
              subtitle: settings.language == 'en' ? 'English' : 'Tiếng Việt',
              icon: Icons.language,
              onTap: () => _showLanguageSelector(context),
            ),
            const Divider(),

            // === SECTION: About ===
            _buildSectionHeader(context, 'About'),
            SettingTile(
              title: 'About App',
              subtitle: 'Version, privacy, etc.',
              icon: Icons.info,
              onTap: () {
                // Chuyển sang màn Info Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InfoScreen()),
                );
              },
            ),

            // Khoảng trắng dưới cùng
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      // fromLTRB: Left, Top, Right, Bottom
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
      ),
    );
  }

  /// Hiển thị dialog chọn đơn vị nhiệt độ
  void _showTemperatureUnitSelector(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    // context.read: không theo dõi, chỉ lấy provider một lần

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temperature Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisSize: chỉ chiếm không gian cần thiết
          children: [
            _buildUnitRadioTile(
              'Celsius (°C)',
              provider.settings.temperatureUnit == TemperatureUnit.celsius,
              () {
                provider.updateTemperatureUnit(TemperatureUnit.celsius);
                Navigator.pop(context);
              },
            ),
            _buildUnitRadioTile(
              'Fahrenheit (°F)',
              provider.settings.temperatureUnit == TemperatureUnit.fahrenheit,
              () {
                provider.updateTemperatureUnit(TemperatureUnit.fahrenheit);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog chọn đơn vị tốc độ gió
  void _showWindSpeedUnitSelector(BuildContext context) {
    final provider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wind Speed Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitRadioTile(
              'Kilometers per hour (km/h)',
              provider.settings.windSpeedUnit == WindSpeedUnit.kmh,
              () {
                provider.updateWindUnit(WindSpeedUnit.kmh);
                Navigator.pop(context);
              },
            ),
            _buildUnitRadioTile(
              'Miles per hour (mph)',
              provider.settings.windSpeedUnit == WindSpeedUnit.mph,
              () {
                provider.updateWindUnit(WindSpeedUnit.mph);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog chọn định dạng giờ
  void _showTimeFormatSelector(BuildContext context) {
    final provider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitRadioTile(
              '24-hour (13:30)',
              provider.settings.timeFormat == TimeFormat.h24,
              () {
                provider.updateTimeFormat(TimeFormat.h24);
                Navigator.pop(context);
              },
            ),
            _buildUnitRadioTile(
              '12-hour (1:30 PM)',
              provider.settings.timeFormat == TimeFormat.h12,
              () {
                provider.updateTimeFormat(TimeFormat.h12);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog chọn ngôn ngữ
  void _showLanguageSelector(BuildContext context) {
    final provider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitRadioTile(
              'English',
              provider.settings.language == 'en',
              () {
                provider.updateLanguage('en');
                Navigator.pop(context);
              },
            ),
            _buildUnitRadioTile(
              'Tiếng Việt',
              provider.settings.language == 'vi',
              () {
                provider.updateLanguage('vi');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper: dòng radio button cho dialog
  Widget _buildUnitRadioTile(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return RadioListTile<bool>(
      // RadioListTile: ListTile với Radio button
      title: Text(label),
      value: true,
      groupValue: isSelected,
      // groupValue: giá trị của nhóm radio (dùng để xác định cái nào được select)
      onChanged: (_) => onTap(),
    );
  }
}