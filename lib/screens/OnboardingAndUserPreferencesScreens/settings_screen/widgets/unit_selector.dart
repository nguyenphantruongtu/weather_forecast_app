import 'package:flutter/material.dart';

/// Widget dialog để chọn đơn vị (nhiệt độ, tốc độ gió, v.v.)
class UnitSelector<T> extends StatelessWidget {
  final String title; // Tiêu đề dialog
  final T selectedValue; // Giá trị hiện tại
  final List<T> options; // Danh sách các lựa chọn
  final List<String> displayNames; // Tên hiển thị của từng lựa chọn
  final ValueChanged<T> onChanged; // Callback khi thay đổi

  const UnitSelector({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.options,
    required this.displayNames,
    required this.onChanged,
  });

  /// Hiển thị dialog
  Future<void> show(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Wrap(
          // Wrap: tự động xuống hàng khi hết chỗ
          spacing: 8, // spacing: khoảng cách giữa các widget
          children: List.generate(
            options.length,
            (index) => ChoiceChip(
              // ChoiceChip: chip có thể select
              label: Text(displayNames[index]),
              selected: options[index] == selectedValue,
              // selected: true nếu là lựa chọn hiện tại
              onSelected: (selected) {
                if (selected) {
                  onChanged(options[index]);
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Widget này chỉ dùng để gọi show(), nên return SizedBox.shrink()
    return SizedBox.shrink();
    // SizedBox.shrink(): widget rỗng (không hiển thị gì)
  }
}
