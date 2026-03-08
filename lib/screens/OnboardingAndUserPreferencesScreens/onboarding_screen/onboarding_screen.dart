import 'package:flutter/material.dart';
import '../location_setup_screen/location_setup_screen.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/page_indicator.dart';

/// Màn hình Onboarding (Màn 1 - Part 2)
/// Hiển thị 3-4 slides giới thiệu app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// PageController: điều khiển PageView (swipe slides)
  /// Cho phép chuyển đến trang cụ thể, lấy trang hiện tại, v.v.
  late PageController _pageController;
  
  int _currentPage = 0;

  /// Danh sách các trang onboarding
  late List<OnboardingPage> pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // initialPage: trang đầu tiên hiển thị

    // Tạo các slide giới thiệu
    pages = [
      OnboardingPage(
        image: 'assets/images/onboarding/weather.png',
        title: 'Real-time Weather',
        description:
            'Get accurate weather information for your location in real-time',
      ),
      OnboardingPage(
        image: 'assets/images/onboarding/forecast.png',
        title: '7-Day Forecast',
        description:
            'Plan your activities with our detailed 7-day weather forecast',
      ),
      OnboardingPage(
        image: 'assets/images/onboarding/alerts.png',
        title: 'Smart Alerts',
        description:
            'Receive notifications about weather changes and alerts',
      ),
      OnboardingPage(
        image: 'assets/images/onboarding/settings.png',
        title: 'Customize Settings',
        description:
            'Adjust temperature units, theme, language and more to your preference',
      ),
    ];
  }

  @override
  void dispose() {
    // Dọn dẹp PageController khi widget bị destroy
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Nút Skip ở góc trên phải
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: _skipToNextScreen,
                // Bỏ qua onboarding, đi tới location setup
                child: const Text('Skip'),
              ),
            ),
          ),
          // PageView: widget cho phép swipe giữa các trang
          // PageView.builder: tạo trang động (hiệu suất tốt)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                // Được gọi khi người dùng swipe tới trang mới
                setState(() => _currentPage = index);
                // setState: cập nhật UI
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                // itemBuilder: hàm tạo mỗi trang
                return OnboardingPageWidget(page: pages[index]);
              },
            ),
          ),
          // Page indicator (chấm chỉ thị trang)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: PageIndicator(
              totalPages: pages.length,
              currentPage: _currentPage,
            ),
          ),
          // Nút điều hướng + Skip ở dưới
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // spaceBetween: khoảng cách đều giữa các item
              children: [
                // Nút Back (ẩn nếu ở trang đầu)
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 60), // Placeholder khi nút Back ẩn
                // Nút Next hoặc Start
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    _currentPage == pages.length - 1 ? 'Start' : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chuyển sang trang tiếp theo
  void _nextPage() {
    if (_currentPage == pages.length - 1) {
      // Nếu ở trang cuối, đi tới màn Location Setup
      _skipToNextScreen();
    } else {
      // Ngược lại, swipe sang trang kế tiếp
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        // duration: thời gian animation
        curve: Curves.easeInOut,
        // curve: kiểu animation (easeInOut: mượt mà)
      );
    }
  }

  /// Quay lại trang trước
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Bỏ qua onboarding, đi tới màn Location Setup
  void _skipToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LocationSetupScreen()),
    );
  }
}