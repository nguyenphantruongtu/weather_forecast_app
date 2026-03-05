import 'package:flutter/material.dart';

/// Widget hiểu diễn một lựa chọn vị trí (Current Location, Search, Popular Cities)
class LocationOptionCard extends StatelessWidget {
  final String title; // Tiêu đề (VD: "Current Location")
  final String description; // Mô tả
  final IconData icon; // Biểu tượng
  final VoidCallback onTap; // Callback khi nhấn vào thẻ
  final Color? backgroundColor; // Màu nền tùy chọn

  const LocationOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // GestureDetector: bắt sự kiện gesture (tap, long press, v.v.)
      onTap: onTap,
      child: Card(
        // Card: widget hiển thị content với shadow và corner radius
        color: backgroundColor ?? Colors.white,
        elevation: 4, // elevation: độ bóng của card
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          // shape: hình dạng của card
          borderRadius: BorderRadius.circular(12),
          // circular: góc bo tròn
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // crossAxisAlignment: căn chỉnh theo trục ngang
            children: [
              // Icon + Title ở hàng trên
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    // Expanded: chiếm phần còn lại của space
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description ở hàng dưới
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
