import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/models/settings_model.dart';
import '../../../utils/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _appearanceOverride;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;
    final languageCode = settings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackground = isDark ? const Color(0xFF11141C) : const Color(0xFFF6F7FB);
    final titleColor = isDark ? Colors.white : const Color(0xFF1C2232);
    final appearance = _appearanceOverride ??
        (settings.theme == AppTheme.dark ? 'dark' : 'light');
    final timePattern = settings.timeFormat == TimeFormat.h24 ? 'HH:mm' : 'h:mm a';
    final currentTime = DateFormat(timePattern).format(DateTime.now());

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: titleColor,
        iconTheme: IconThemeData(color: titleColor),
        title: Text(
          AppStrings.tr(
            languageCode,
            en: 'Settings & Preferences',
            vi: 'Cài đặt & Tùy chỉnh',
          ),
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _sectionLabel(AppStrings.tr(languageCode, en: 'UNITS', vi: 'ĐƠN VỊ')),
          _card(
            child: Column(
              children: [
                _settingRow(
                  icon: Icons.thermostat,
                  iconColor: const Color(0xFF6FA1F0),
                  title: AppStrings.tr(languageCode, en: 'Temperature', vi: 'Nhiệt độ'),
                  trailing: _InlineBinarySwitch(
                    leftText: '°C',
                    rightText: '°F',
                    isRightSelected:
                        settings.temperatureUnit == TemperatureUnit.fahrenheit,
                    onChanged: (right) {
                      settingsProvider.updateTemperatureUnit(
                        right
                            ? TemperatureUnit.fahrenheit
                            : TemperatureUnit.celsius,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _settingRow(
                  icon: Icons.air,
                  iconColor: const Color(0xFF77AFE8),
                  title: AppStrings.tr(languageCode, en: 'Wind Speed', vi: 'Tốc độ gió'),
                  trailing: _InlineBinarySwitch(
                    leftText: 'km/h',
                    rightText: 'mph',
                    isRightSelected: settings.windSpeedUnit == WindSpeedUnit.mph,
                    onChanged: (right) {
                      settingsProvider.updateWindUnit(
                        right ? WindSpeedUnit.mph : WindSpeedUnit.kmh,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(AppStrings.tr(languageCode, en: 'APPEARANCE', vi: 'GIAO DIỆN')),
          _card(
            child: Row(
              children: [
                Expanded(
                  child: _appearanceTile(
                    label: AppStrings.tr(languageCode, en: 'Light', vi: 'Sáng'),
                    icon: Icons.light_mode,
                    selected: appearance == 'light',
                    onTap: () {
                      settingsProvider.updateTheme(AppTheme.light);
                      setState(() => _appearanceOverride = 'light');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _appearanceTile(
                    label: AppStrings.tr(languageCode, en: 'Dark', vi: 'Tối'),
                    icon: Icons.dark_mode,
                    selected: appearance == 'dark',
                    onTap: () {
                      settingsProvider.updateTheme(AppTheme.dark);
                      setState(() => _appearanceOverride = 'dark');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _appearanceTile(
                    label: AppStrings.tr(languageCode, en: 'Auto', vi: 'Tự động'),
                    icon: Icons.brightness_4,
                    selected: appearance == 'auto',
                    onTap: () {
                      final brightness = MediaQuery.platformBrightnessOf(context);
                      settingsProvider.updateTheme(
                        brightness == Brightness.dark
                            ? AppTheme.dark
                            : AppTheme.light,
                      );
                      setState(() => _appearanceOverride = 'auto');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(AppStrings.tr(languageCode, en: 'TIME & DATE', vi: 'THỜI GIAN & NGÀY')),
          _card(
            child: Column(
              children: [
                _settingRow(
                  icon: Icons.schedule,
                  iconColor: const Color(0xFF76ACE8),
                  title: AppStrings.tr(languageCode, en: 'Time Format', vi: 'Định dạng giờ'),
                  trailing: _InlineBinarySwitch(
                    leftText: '12h',
                    rightText: '24h',
                    isRightSelected: settings.timeFormat == TimeFormat.h24,
                    onChanged: (right) {
                      settingsProvider.updateTimeFormat(
                        right ? TimeFormat.h24 : TimeFormat.h12,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      '${AppStrings.tr(languageCode, en: 'Current time', vi: 'Giờ hiện tại')}: $currentTime',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA1A9BC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(AppStrings.tr(languageCode, en: 'LANGUAGE', vi: 'NGÔN NGỮ')),
          _card(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showLanguageSelector(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const _IconBadge(
                      icon: Icons.language,
                      color: Color(0xFF76ACE8),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.tr(languageCode, en: 'Language', vi: 'Ngôn ngữ'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1F2637),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      settings.language == 'en' ? 'English' : 'Tiếng Việt',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFBAC2D6) : const Color(0xFF9098AD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFC3C8D7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(AppStrings.tr(languageCode, en: 'APP INFO', vi: 'THONG TIN UNG DUNG')),
          _card(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pushNamed(context, '/info');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const _IconBadge(
                      icon: Icons.info_outline,
                      color: Color(0xFF76ACE8),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.tr(languageCode, en: 'About & Help', vi: 'Thong tin & Tro giup'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1F2637),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFC3C8D7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          color: isDark ? const Color(0xFF9FA9C2) : const Color(0xFFB0B7C7),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3143) : const Color(0xFFE8ECF4),
        ),
      ),
      child: child,
    );
  }

  Widget _settingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        _IconBadge(icon: icon, color: iconColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1F2637),
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }

  Widget _appearanceTile({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFF1D2340) : const Color(0xFFF4F6FB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : const Color(0xFF8F97AB),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF8F97AB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    final languageCode = provider.settings.language;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr(languageCode, en: 'Select Language', vi: 'Chọn ngôn ngữ')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageTile(
              'English',
              provider.settings.language == 'en',
              () {
                provider.updateLanguage('en');
                Navigator.pop(context);
              },
            ),
            _languageTile(
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

  Widget _languageTile(String label, bool isSelected, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? const Color(0xFF4C9BF0) : const Color(0xFFB2B8C8),
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _InlineBinarySwitch extends StatelessWidget {
  final String leftText;
  final String rightText;
  final bool isRightSelected;
  final ValueChanged<bool> onChanged;

  const _InlineBinarySwitch({
    required this.leftText,
    required this.rightText,
    required this.isRightSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          leftText,
          style: TextStyle(
            color: isRightSelected ? const Color(0xFFA3AABD) : const Color(0xFF4D5466),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(!isRightSelected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 20,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isRightSelected ? const Color(0xFF4C9BF0) : const Color(0xFFD8DCE8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Align(
              alignment: isRightSelected ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rightText,
          style: TextStyle(
            color: isRightSelected ? const Color(0xFF4D5466) : const Color(0xFFA3AABD),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}