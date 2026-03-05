import 'package:flutter/material.dart';

/// Dialog xin quyền truy cập vị trí từ người dùng
class PermissionDialog extends StatelessWidget {
  final String title; // Tiêu đề dialog
  final String message; // Nội dung yêu cầu
  final VoidCallback onAllow; // Callback khi nhấn "Allow"
  final VoidCallback onDeny; // Callback khi nhấn "Deny"

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // AlertDialog: dialog chuẩn của Material Design
      title: Text(title),
      content: Text(message),
      actions: [
        // actions: danh sách nút ở dưới dialog
        TextButton(
          onPressed: onDeny,
          child: const Text(
            'Deny',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: onAllow,
          child: const Text('Allow'),
        ),
      ],
    );
  }

  /// Hàm static để hiển thị dialog
  /// static: phương thức thuộc class, không cấn instance
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      // showDialog: hiển thị dialog, trả về Future<bool>
      context: context,
      barrierDismissible: false,
      // barrierDismissible: false = không thể tap ngoài dialog để đóng
      builder: (context) => PermissionDialog(
        title: title,
        message: message,
        onAllow: () => Navigator.pop(context, true),
        // Navigator.pop với giá trị true = nhấn Allow
        onDeny: () => Navigator.pop(context, false),
        // Navigator.pop với giá trị false = nhấn Deny
      ),
    );
  }
}
