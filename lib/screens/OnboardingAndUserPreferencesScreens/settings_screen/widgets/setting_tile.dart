import 'package:flutter/material.dart';

/// Widget hiển thị một dòng cài đặt (VD: Temperature Unit, Theme, Language)
class SettingTile extends StatelessWidget {
  final String title; // Tiêu đề cài đặt
  final String subtitle; // Giá trị hiện tại
  final IconData icon; // Biểu tượng
  final VoidCallback onTap; // Callback khi nhấn vào

  const SettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // ListTile: widget hiển thị một item trong list
      leading: Icon(icon, color: Colors.blue),
      // leading: widget hiển thị ở bên trái
      title: Text(title),
      subtitle: Text(subtitle),
      // subtitle: text nhỏ ở dưới title
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      // trailing: widget hiển thị ở bên phải
      onTap: onTap,
    );
  }
}

/// Widget hiển thị một cài đặt toggle (VD: Dark mode on/off)
class ToggleSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value; // Giá trị hiện tại (true/false)
  final ValueChanged<bool> onChanged; // Callback khi thay đổi

  const ToggleSettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        // Switch: widget toggle on/off
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
