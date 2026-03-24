import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../calendar_screen/utils/temperature_gradient.dart';
import '../models/chart_data_model.dart';

class UvHeatmap extends StatelessWidget {
  const UvHeatmap({super.key, required this.items});

  final List<UvHeatmapItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No UV data', style: TextStyle(color: Colors.white70)),
      );
    }
    return GridView.builder(
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, index) {
        final uv = items[index].uv;
        return Tooltip(
          message: '${items[index].dateLabel}: ${uv.toStringAsFixed(1)}',
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TemperatureGradient.uvColor(uv).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              uv.toStringAsFixed(0),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}
