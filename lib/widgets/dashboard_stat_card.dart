import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.itim(
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.itim(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}