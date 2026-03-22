import 'package:flutter/material.dart';
import '../../../../data/models/notification_config_model.dart';

class TimePickerTile extends StatelessWidget {
  final TimeOfDayModel time;
  final ValueChanged<TimeOfDayModel> onTimeChanged;

  const TimePickerTile({
    super.key,
    required this.time,
    required this.onTimeChanged,
  });

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B7AEF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeChanged(TimeOfDayModel(hour: picked.hour, minute: picked.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickTime(context),
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E3FF)),
        ),
        child: Row(
          children: [
            Text(
              time.formatted,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}