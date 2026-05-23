import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PointsBadge extends StatelessWidget {
  final int points;
  const PointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A017), // gold
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            '$points pts',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2C1A0E), // dark brown text
            ),
          ),
        ],
      ),
    );
  }
}