import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});

  final List<MapEntry<String, Color>> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: items
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: e.value,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  e.key,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
