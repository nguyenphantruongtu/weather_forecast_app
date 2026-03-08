import 'package:flutter/material.dart';

/// Widget hiển thị chấm chỉ thị trang hiện tại
/// VD: ● ○ ○ (trang 1 trong 3 trang)
class PageIndicator extends StatelessWidget {
  final int totalPages; // Tổng số trang
  final int currentPage; // Trang hiện tại
  final Color activeColor; // Màu chấm đang active
  final Color inactiveColor; // Màu chấm không active

  const PageIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // Row: xếp widget theo chiều ngang
      mainAxisAlignment: MainAxisAlignment.center,
      // Căn giữa các chấm
      children: List.generate(
        // List.generate: tạo list với số lượng xác định
        totalPages,
        (index) => Container(
          // Mỗi chấm là một Container
          width: index == currentPage ? 12 : 8,
          // Chấm hiện tại to hơn các chấm khác
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Hình tròn
            color: index == currentPage ? activeColor : inactiveColor,
            // Màu khác nhau dựa trên index
          ),
        ),
      ),
    );
  }
}
