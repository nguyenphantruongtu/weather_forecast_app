import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/weather_day_model.dart';
import 'date_cell.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.weatherByDay,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Map<DateTime, WeatherDayModel> weatherByDay;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.15, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy').format(focusedMonth),
                    key: ValueKey('${focusedMonth.month}-${focusedMonth.year}'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          TableCalendar<WeatherDayModel>(
            firstDay: DateTime(2021, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            focusedDay: focusedMonth,
            selectedDayPredicate: (day) =>
                DateUtils.isSameDay(day, selectedDate),
            onDaySelected: (selectedDay, _) => onDateSelected(selectedDay),
            onPageChanged: onMonthChanged,
            headerVisible: false,
            rowHeight: 56,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.inter(color: Colors.white70),
              weekendStyle: GoogleFonts.inter(color: Colors.white70),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
              selectedDecoration: BoxDecoration(color: Colors.transparent),
              todayDecoration: BoxDecoration(color: Colors.transparent),
              defaultDecoration: BoxDecoration(color: Colors.transparent),
              outsideDecoration: BoxDecoration(color: Colors.transparent),
            ),
            calendarBuilders: CalendarBuilders<WeatherDayModel>(
              defaultBuilder: (_, day, fDay) =>
                  _buildCell(day, fDay, selectedDate, false),
              todayBuilder: (_, day, fDay) =>
                  _buildCell(day, fDay, selectedDate, true),
              selectedBuilder: (_, day, fDay) =>
                  _buildCell(day, fDay, selectedDate, false),
              outsideBuilder: (_, day, fDay) =>
                  _buildCell(day, fDay, selectedDate, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    DateTime day,
    DateTime focusedDay,
    DateTime selected,
    bool isTodayFlag,
  ) {
    final key = DateTime(day.year, day.month, day.day);
    return DateCell(
      day: day,
      isToday: isTodayFlag || DateUtils.isSameDay(day, DateTime.now()),
      isSelected: DateUtils.isSameDay(day, selected),
      isOutside: day.month != focusedDay.month,
      weather: weatherByDay[key],
      onTap: () => onDateSelected(day),
    );
  }
}
