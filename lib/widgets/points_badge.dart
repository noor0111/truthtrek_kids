// points_badge.dart
// This widget shows the child's total points as a yellow badge.
// It appears on the home screen header.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PointsBadge extends StatelessWidget {
  // points = the number to display
  final int points;

  const PointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Styling the badge — yellow background, rounded corners
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD600), // bright yellow
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Star emoji
          const Text('⭐', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          // Points number
          Text(
            '$points pts',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A1A8A), // dark purple text
            ),
          ),
        ],
      ),
    );
  }
}