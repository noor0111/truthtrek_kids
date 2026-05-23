// truth_meter.dart
// This widget shows a colored bar that fills based on the verdict.
// GREEN = TRUE, RED = MISLEADING, YELLOW = NEEDS VERIFICATION

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/claim_result.dart';

class TruthMeter extends StatelessWidget {
  final Verdict verdict;

  const TruthMeter({super.key, required this.verdict});

  // Returns the color based on verdict
  Color get barColor {
    if (verdict == Verdict.tru) {
      return const Color(0xFF2ECC71); // green
    } else if (verdict == Verdict.misleading) {
      return const Color(0xFFE74C3C); // red
    } else {
      return const Color(0xFFFFD600); // yellow
    }
  }

  // Returns how much of the bar to fill (0.0 to 1.0)
  double get fillAmount {
    if (verdict == Verdict.tru) {
      return 1.0;   // full bar
    } else if (verdict == Verdict.misleading) {
      return 0.2;   // almost empty
    } else {
      return 0.55;  // half full
    }
  }

  // Returns the label text
  String get label {
    if (verdict == Verdict.tru) {
      return 'TRUTH LEVEL: HIGH ✅';
    } else if (verdict == Verdict.misleading) {
      return 'TRUTH LEVEL: LOW ⚠️';
    } else {
      return 'TRUTH LEVEL: UNCERTAIN 🔍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the bar
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),

        // The bar background (grey track)
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          // The colored fill inside the bar
          child: FractionallySizedBox(
            widthFactor: fillAmount,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}