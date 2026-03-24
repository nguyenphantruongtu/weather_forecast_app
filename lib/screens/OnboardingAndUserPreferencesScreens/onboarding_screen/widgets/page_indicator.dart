import 'package:flutter/material.dart';

/// Widget hiển thị chấm chỉ thị trang hiện tại
/// VD: ● ○ ○ (trang 1 trong 3 trang)
class PageIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color activeColor;
  final Color inactiveColor;

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
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          width: index == currentPage ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: index == currentPage ? activeColor : inactiveColor,
          ),
        ),
      ),
    );
  }
}
