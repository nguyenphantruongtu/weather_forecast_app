import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utils/app_strings.dart';
import 'services/location_api_service.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;
  final LocationApiService _locationApiService = LocationApiService();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 44),
              _permissionVisual(),
              const SizedBox(height: 34),
              Text(
                AppStrings.tr(languageCode, en: 'Enable Location Access', vi: 'Bat quyen truy cap vi tri'),
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _bullet(AppStrings.tr(languageCode, en: 'Accurate local forecasts', vi: 'Du bao dia phuong chinh xac')),
              const SizedBox(height: 8),
              _bullet(AppStrings.tr(languageCode, en: 'Severe weather alerts', vi: 'Canh bao thoi tiet khac nghiet')),
              const SizedBox(height: 8),
              _bullet(AppStrings.tr(languageCode, en: 'No location data sharing without your consent', vi: 'Khong chia se du lieu vi tri khi chua co su dong y')),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestAccess,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.tr(languageCode, en: 'Allow Location Access', vi: 'Cho phep truy cap vi tri'),
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.tr(languageCode, en: 'Enter Manually', vi: 'Nhap thu cong'),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionVisual() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDCE8F9), width: 2),
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFF4C9BF0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.place, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(Icons.check_circle, color: Color(0xFF54C77D), size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6E778D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestAccess() async {
    final languageCode = context.read<SettingsProvider>().settings.language;
    setState(() => _isLoading = true);

    try {
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      }

      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.tr(languageCode, en: 'Please enable location services first.', vi: 'Vui long bat dich vu vi tri truoc.'))),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.tr(languageCode, en: 'Location is permanently denied. Opened app settings.', vi: 'Quyen vi tri bi tu choi vinh vien. Da mo cai dat ung dung.'))),
          );
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.tr(languageCode, en: 'Location permission was denied.', vi: 'Quyen vi tri da bi tu choi.'))),
          );
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.tr(languageCode, en: 'Could not determine your current location. Please try again.', vi: 'Khong xac dinh duoc vi tri hien tai. Vui long thu lai.'))),
          );
        }
        return;
      }

      final locationChoice = await _locationApiService.resolveCurrentLocation(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        Navigator.pop(
          context,
          locationChoice,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.tr(languageCode, en: 'Could not access your location. Try search manually.', vi: 'Khong the truy cap vi tri. Hay thu tim thu cong.'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
