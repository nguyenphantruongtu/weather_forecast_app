import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/widget_config_model.dart';
import 'widget_size_badge.dart';

class WidgetPreviewCard extends StatelessWidget {
  const WidgetPreviewCard({
    super.key,
    required this.widgetSize,
    required this.theme,
  });

  final AppWidgetSize widgetSize;
  final AppWidgetTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildWidgetPreview(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widgetSize.isPopular) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCC00),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Popular',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    WidgetSizeBadge(label: widgetSize.size),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widgetSize.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Color(0xFF007AFF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Calendar',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.bar_chart,
                      size: 12,
                      color: Color(0xFF007AFF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Statistics',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetPreview() {
    if (widgetSize.name.contains('Calendar')) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 32,
            color: theme.textColor.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            '28°',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.textColor,
            ),
          ),
          Text(
            'Hanoi',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: theme.textColor.withOpacity(0.7),
            ),
          ),
        ],
      );
    }
    if (widgetSize.name.contains('Statistics')) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 32,
            color: theme.textColor.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            'Statistics',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textColor,
            ),
          ),
        ],
      );
    }
    if (widgetSize.name.contains('Current')) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text('☀️', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '28°',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: theme.textColor,
                    ),
                  ),
                  Text(
                    'Partly Cloudy',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.textColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('☀️', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          '28°',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }
}
