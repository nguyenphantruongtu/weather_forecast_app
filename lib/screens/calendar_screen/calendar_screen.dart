\import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/calendar_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/widget_config_provider.dart';
import 'widgets/date_cell_widget.dart';
import 'widgets/date_detail_bottom_sheet.dart';
import 'widgets/month_summary_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProv = context.read<LocationProvider>();
      final calendarProv = context.read<CalendarProvider>();

      // Update calendar provider with current location if available
      if (locationProv.selectedCity != null) {
        calendarProv.updateLocation(
          locationProv.selectedCity!.latitude,
          locationProv.selectedCity!.longitude,
        );
      }

      calendarProv.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetTheme = context.watch<WidgetConfigProvider>().selectedTheme;
    final isDark = widgetTheme.name == 'Dark Mode';
    final accentColor = isDark ? Colors.white : widgetTheme.color;

    return Scaffold(
      backgroundColor:
          isDark ? widgetTheme.color : widgetTheme.color.withOpacity(0.1),
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: widgetTheme.textColor),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Weather Calendar',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widgetTheme.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: widgetTheme.textColor),
            onPressed: () {
              context.read<CalendarProvider>().loadMonth(_focusedDay);
            },
          ),
        ],
        backgroundColor: widgetTheme.color,
        elevation: 0,
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.weatherData.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          }

          if (provider.errorMessage != null && provider.weatherData.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Conflict resolved: kept formatted version from branch 5502e66
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: GoogleFonts.inter(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadMonth(_focusedDay),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const MonthSummaryCard(),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar<void>(
                    firstDay: DateTime(2020, 1, 1),
                    lastDay: DateTime(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    rowHeight: 72,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: accentColor,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: accentColor,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        // Conflict resolved: dùng accentColor từ HEAD
                        // vì branch này đã tính accentColor dựa trên widgetTheme,
                        // nhất quán với toàn bộ file thay vì dùng Theme.of(context)
                        color: accentColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      todayTextStyle: TextStyle(
                        color: isDark ? Colors.black87 : accentColor,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      weekendStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders<void>(
                      defaultBuilder: (context, day, focusedDay) {
                        final weather = provider.getWeatherForDate(day);
                        return DateCellWidget(
                          date: day,
                          weather: weather,
                          isToday: isSameDay(day, DateTime.now()),
                          isSelected: isSameDay(day, _selectedDay),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final weather = provider.getWeatherForDate(day);
                        return DateCellWidget(
                          date: day,
                          weather: weather,
                          isToday: true,
                          isSelected: isSameDay(day, _selectedDay),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final weather = provider.getWeatherForDate(day);
                        return DateCellWidget(
                          date: day,
                          weather: weather,
                          isToday: isSameDay(day, DateTime.now()),
                          isSelected: true,
                        );
                      },
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      provider.selectDate(selectedDay);
                      _showDateDetail(context, selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      provider.loadMonth(focusedDay);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDateDetail(BuildContext context, DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateDetailBottomSheet(date: date),
    );
  }
}