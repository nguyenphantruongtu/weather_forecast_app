import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'widgets/faq_item.dart';
import 'widgets/about_section.dart';

/// Màn hình Thông tin & Giúp đỡ (Màn 4 - App Info & Help)
/// Hiển thị About, FAQ, Privacy Policy, Terms, Rating, Share
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Help'),
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
              content: 'Version 1.0.0\n\n'
                  'A modern weather forecasting app that provides real-time weather data, '
                  '7-day forecasts, and smart weather alerts.\n\n'
                  '© 2024 WeatherNow. All rights reserved.',
            ),

            // === SECTION: How to Use ===
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'How to Use',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            FAQItem(
              question: 'How do I set my location?',
              answer:
                  'You can set your location in two ways:\n'
                  '1. Use Current Location: Allow GPS access for automatic detection\n'
                  '2. Search City: Manually search for any city in the world\n'
                  '3. Popular Cities: Choose from our list of commonly selected cities',
            ),
            FAQItem(
              question: 'How do I customize the app settings?',
              answer:
                  'Go to Settings to:\n'
                  '• Change temperature units (°C or °F)\n'
                  '• Change wind speed units (km/h or mph)\n'
                  '• Enable/disable dark mode\n'
                  '• Choose time format (12-hour or 24-hour)\n'
                  '• Select your preferred language',
            ),
            FAQItem(
              question: 'How do I get weather alerts?',
              answer:
                  'Weather alerts are automatically sent based on significant weather changes '
                  'in your location. Make sure to:\n'
                  '• Enable notifications in app settings\n'
                  '• Allow notification permissions\n'
                  '• Keep the app installed',
            ),
            FAQItem(
              question: 'Can I export my weather data?',
              answer:
                  'Yes! You can export weather data as CSV file from the main screen. '
                  'Tap the menu icon and select "Export Data".',
            ),

            // === SECTION: Privacy & Terms ===
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Legal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            AboutSection(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              content: 'WeatherNow respects your privacy. We collect only necessary location '
                  'data to provide weather services. Your data is never sold to third parties.\n\n'
                  'For detailed information, visit: privacy.weathernow.app',
            ),
            AboutSection(
              icon: Icons.description,
              title: 'Terms of Service',
              content: 'By using WeatherNow, you agree to our Terms of Service. '
                  'The weather data is provided by trusted weather APIs and may not be '
                  '100% accurate in all cases.\n\n'
                  'For more details, visit: terms.weathernow.app',
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
                    label: const Text('Rate App'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nút Share App
                  OutlinedButton.icon(
                    onPressed: _shareApp,
                    icon: const Icon(Icons.share),
                    label: const Text('Share App'),
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