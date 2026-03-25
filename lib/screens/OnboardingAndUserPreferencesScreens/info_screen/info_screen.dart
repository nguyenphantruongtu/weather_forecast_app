import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
import 'widgets/faq_item.dart';
import 'widgets/about_section.dart';

/// Màn hình Thông tin & Giúp đỡ (Màn 4 - App Info & Help)
/// Hiển thị About, FAQ, Privacy Policy, Terms, Rating, Share
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(languageCode, en: 'About & Help', vi: 'Thong tin & Tro giup')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === SECTION: App Information ===
            AboutSection(
              icon: Icons.info,
              title: 'WeatherNow',
              content: AppStrings.tr(
                languageCode,
                en: 'Version 1.0.0\n\nA modern weather forecasting app that provides real-time weather data, 7-day forecasts, and smart weather alerts.\n\n© 2024 WeatherNow. All rights reserved.',
                vi: 'Phien ban 1.0.0\n\nUng dung du bao thoi tiet hien dai cung cap du lieu thoi tiet thoi gian thuc, du bao 7 ngay va canh bao thong minh.\n\n© 2024 WeatherNow. Bao luu moi quyen.',
              ),
            ),

            // === SECTION: How to Use ===
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                AppStrings.tr(languageCode, en: 'How to Use', vi: 'Huong dan su dung'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            FAQItem(
              question: AppStrings.tr(languageCode, en: 'How do I set my location?', vi: 'Lam sao de cai dat vi tri?'),
              answer: AppStrings.tr(
                languageCode,
                en: 'You can set your location in two ways:\n1. Use Current Location: Allow GPS access for automatic detection\n2. Search City: Manually search for any city in the world\n3. Popular Cities: Choose from our list of commonly selected cities',
                vi: 'Ban co the cai dat vi tri theo hai cach:\n1. Dung vi tri hien tai: Cho phep GPS de tu dong nhan dien\n2. Tim thanh pho: Tim thu cong bat ky thanh pho nao\n3. Thanh pho pho bien: Chon tu danh sach de xuat',
              ),
            ),
            FAQItem(
              question: AppStrings.tr(languageCode, en: 'How do I customize the app settings?', vi: 'Lam sao de tuy chinh cai dat ung dung?'),
              answer: AppStrings.tr(
                languageCode,
                en: 'Go to Settings to:\n• Change temperature units (°C or °F)\n• Change wind speed units (km/h or mph)\n• Enable/disable dark mode\n• Choose time format (12-hour or 24-hour)\n• Select your preferred language',
                vi: 'Vao Cai dat de:\n• Doi don vi nhiet do (°C hoac °F)\n• Doi don vi toc do gio (km/h hoac mph)\n• Bat/tat che do toi\n• Chon dinh dang gio (12h hoac 24h)\n• Chon ngon ngu ua thich',
              ),
            ),
            FAQItem(
              question: AppStrings.tr(languageCode, en: 'How do I get weather alerts?', vi: 'Lam sao de nhan canh bao thoi tiet?'),
              answer: AppStrings.tr(
                languageCode,
                en: 'Weather alerts are automatically sent based on significant weather changes in your location. Make sure to:\n• Enable notifications in app settings\n• Allow notification permissions\n• Keep the app installed',
                vi: 'Canh bao thoi tiet duoc gui tu dong dua tren thay doi dang ke tai vi tri cua ban. Hay dam bao:\n• Da bat thong bao trong cai dat\n• Da cap quyen thong bao\n• Van giu ung dung da cai dat',
              ),
            ),
            FAQItem(
              question: AppStrings.tr(languageCode, en: 'Can I export my weather data?', vi: 'Toi co the xuat du lieu thoi tiet khong?'),
              answer: AppStrings.tr(
                languageCode,
                en: 'Yes! You can export weather data as CSV file from the main screen. Tap the menu icon and select "Export Data".',
                vi: 'Co! Ban co the xuat du lieu thoi tiet dang CSV tu man hinh chinh. Bam bieu tuong menu va chon "Xuat du lieu".',
              ),
            ),

            // === SECTION: Privacy & Terms ===
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                AppStrings.tr(languageCode, en: 'Legal', vi: 'Phap ly'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            AboutSection(
              icon: Icons.privacy_tip,
              title: AppStrings.tr(languageCode, en: 'Privacy Policy', vi: 'Chinh sach quyen rieng tu'),
              content: AppStrings.tr(
                languageCode,
                en: 'WeatherNow respects your privacy. We collect only necessary location data to provide weather services. Your data is never sold to third parties.\n\nFor detailed information, visit: privacy.weathernow.app',
                vi: 'WeatherNow ton trong quyen rieng tu cua ban. Chung toi chi thu thap du lieu vi tri can thiet de cung cap dich vu thoi tiet. Du lieu cua ban khong bao gio duoc ban cho ben thu ba.\n\nXem chi tiet tai: privacy.weathernow.app',
              ),
            ),
            AboutSection(
              icon: Icons.description,
              title: AppStrings.tr(languageCode, en: 'Terms of Service', vi: 'Dieu khoan dich vu'),
              content: AppStrings.tr(
                languageCode,
                en: 'By using WeatherNow, you agree to our Terms of Service. The weather data is provided by trusted weather APIs and may not be 100% accurate in all cases.\n\nFor more details, visit: terms.weathernow.app',
                vi: 'Khi su dung WeatherNow, ban dong y voi Dieu khoan dich vu cua chung toi. Du lieu thoi tiet duoc cung cap boi cac API dang tin cay va co the khong chinh xac 100% trong moi truong hop.\n\nXem chi tiet tai: terms.weathernow.app',
              ),
            ),

            // === SECTION: Actions ===
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Nút Rate App
                  ElevatedButton.icon(
                    onPressed: _rateApp,
                    icon: const Icon(Icons.star),
                    label: Text(AppStrings.tr(languageCode, en: 'Rate App', vi: 'Danh gia ung dung')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nút Share App
                  OutlinedButton.icon(
                    onPressed: _shareApp,
                    icon: const Icon(Icons.share),
                    label: Text(AppStrings.tr(languageCode, en: 'Share App', vi: 'Chia se ung dung')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mở App Store để rating
  Future<void> _rateApp() async {
    // URL để mở app store (thay đổi theo platform)
    const url = 'https://play.google.com/store/apps/details?id=com.weathernow.app';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        // launchUrl: mở URL trong browser hoặc app store
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  /// Chia sẻ app
  Future<void> _shareApp() async {
    await Share.share(
      'Check out WeatherNow - A beautiful weather forecasting app!\n'
      'Download here: https://weathernow.app',
      // Share.share: popup để chia sẻ văn bản
    );
  }
}