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
  late PageController _pageController;

  int _currentPage = 0;
  late List<OnboardingPage> pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    pages = [
      OnboardingPage(
        title: 'Smart Weather Alerts',
        description:
            'Receive instant alerts about rain, storms, and extreme weather so you are always prepared.',
        artType: OnboardingArtType.smartWeather,
      ),
      OnboardingPage(
        title: 'Stay Informed with Alerts',
        description:
            'Receive timely notifications about severe weather conditions and personalized safety checklists.',
        artType: OnboardingArtType.informedAlerts,
      ),
      OnboardingPage(
        title: 'Track Multiple Locations',
        description:
            'Save your home, office, and favorite travel spots to receive weather updates all in one place.',
        artType: OnboardingArtType.multiLocation,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 6, right: 16),
                child: TextButton(
                  onPressed: _skipToNextScreen,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB5B8C6),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              allowImplicitScrolling: true,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return OnboardingPageWidget(page: pages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PageIndicator(
              totalPages: pages.length,
              currentPage: _currentPage,
              activeColor: const Color(0xFF4C9BF0),
              inactiveColor: const Color(0xFFC9CEDC),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isLastPage ? double.infinity : 94,
              height: 40,
              margin: EdgeInsets.only(left: isLastPage ? 0 : 0),
              alignment: isLastPage ? Alignment.center : Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(isLastPage ? double.infinity : 94, 40),
                  backgroundColor: const Color(0xFF4C9BF0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == pages.length - 1) {
      _skipToNextScreen();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LocationSetupScreen()),
    );
  }
}