import 'package:flutter/material.dart';

/// Widget biểu diễn một trang onboarding
/// Hiển thị ảnh, tiêu đề, mô tả cho mỗi slide
class OnboardingPage {
  final String image; // Đường dẫn ảnh
  final String title; // Tiêu đề slide
  final String description; // Mô tả chi tiết

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Widget hiển thị một trang onboarding
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      // Column: xếp các widget theo chiều dọc
      mainAxisAlignment: MainAxisAlignment.center,
      // mainAxisAlignment: căn chỉnh theo chiều chính (dọc)
      children: [
        // Ảnh slide - Sử dụng Icon thay vì Image.asset() để chạy ngay
        _buildSlideIcon(page.title),
        const SizedBox(height: 40),
        // Tiêu đề
        Text(
          page.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          // textAlign: căn chỉnh text
        ),
        const SizedBox(height: 16),
        // Mô tả
        Padding(
          // Padding: thêm khoảng cách quanh widget
          padding: const EdgeInsets.symmetric(horizontal: 24),
          // symmetric: khoảng cách có chỉ định trục (horizontal, vertical)
          child: Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Helper: Tạo icon dựa trên tiêu đề slide
  Widget _buildSlideIcon(String title) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
    ];

    final icons = [
      Icons.cloud,
      Icons.calendar_month,
      Icons.notifications_active,
      Icons.settings,
    ];

    int index = 0;
    if (title.contains('7-Day')) index = 1;
    if (title.contains('Smart')) index = 2;
    if (title.contains('Customize')) index = 3;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colors[index].withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icons[index],
        color: colors[index],
        size: 60,
      ),
    );
  }
}
