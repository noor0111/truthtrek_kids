import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/claim_result.dart';

class TruthMeter extends StatelessWidget {
  final Verdict verdict;
  const TruthMeter({super.key, required this.verdict});

  Color get barColor {
    if (verdict == Verdict.tru) {
      return const Color(0xFF2D6A4F); // forest green
    } else if (verdict == Verdict.misleading) {
      return const Color(0xFF8B2500); // dark red
    } else {
      return const Color(0xFFD4A017); // gold
    }
  }

  double get fillAmount {
    if (verdict == Verdict.tru) return 1.0;
    if (verdict == Verdict.misleading) return 0.2;
    return 0.55;
  }

  String get label {
    if (verdict == Verdict.tru) return 'TRUTH LEVEL: HIGH ✅';
    if (verdict == Verdict.misleading) return 'TRUTH LEVEL: LOW ⚠️';
    return 'TRUTH LEVEL: UNCERTAIN 🔍';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
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