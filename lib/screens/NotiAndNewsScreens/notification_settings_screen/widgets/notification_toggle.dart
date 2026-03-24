import 'package:flutter/material.dart';

class NotificationToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool alwaysOn;
  final String? warningText;
  final IconData? leadingIcon;
  final Color? iconColor;

  const NotificationToggle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.alwaysOn = false,
    this.warningText,
    this.leadingIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 20, color: iconColor ?? Colors.grey[600]),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                if (warningText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    warningText!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (alwaysOn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ON',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE65100),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF6B7AEF),
            ),
        ],
      ),
    );
  }
}