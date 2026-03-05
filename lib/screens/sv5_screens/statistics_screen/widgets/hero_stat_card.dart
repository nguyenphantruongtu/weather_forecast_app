import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroStatCard extends StatelessWidget {
  const HeroStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.delta,
  });

  final String title;
  final String value;
  final String subtitle;
  final double delta;

  @override
  Widget build(BuildContext context) {
    final isPositive = delta >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea).withValues(alpha: 0.8),
            const Color(0xFF764ba2).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
              ),
              Text(
                '${delta.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
