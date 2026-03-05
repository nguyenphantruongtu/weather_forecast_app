import 'package:flutter/material.dart';

/// Widget hiển thị section thông tin (About, Privacy, Terms, v.v.)
class AboutSection extends StatelessWidget {
  final String title; // Tiêu đề section
  final String content; // Nội dung
  final IconData? icon; // Biểu tượng tùy chọn

  const AboutSection({
    super.key,
    required this.title,
    required this.content,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và title
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.blue),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6, // height: khoảng cách dòng
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
