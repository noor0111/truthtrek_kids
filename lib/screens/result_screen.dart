// result_screen.dart
// This screen shows the result after all 3 agents finish.
// It shows the verdict, explanation, points earned, and parent alert.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/claim_result.dart';
import '../widgets/truth_meter.dart';

class ResultScreen extends StatelessWidget {
  // The result passed from the home screen
  final ClaimResult result;

  const ResultScreen({super.key, required this.result});

  // Returns background color based on verdict
  Color get cardColor {
    if (result.verdict == Verdict.tru) {
      return const Color(0xFF1A7A4A); // dark green
    } else if (result.verdict == Verdict.misleading) {
      return const Color(0xFF8B1A1A); // dark red
    } else {
      return const Color(0xFF7A5A00); // dark yellow
    }
  }

  // Returns the big emoji for the verdict
  String get verdictEmoji {
    if (result.verdict == Verdict.tru) return '✅';
    if (result.verdict == Verdict.misleading) return '⚠️';
    return '🔍';
  }

  // Returns the verdict label text
  String get verdictLabel {
    if (result.verdict == Verdict.tru) return 'TRUE';
    if (result.verdict == Verdict.misleading) return 'MISLEADING';
    return 'NEEDS VERIFICATION';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cardColor, const Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      buildVerdictCard(),
                      const SizedBox(height: 20),
                      buildExplanationCard(),
                      const SizedBox(height: 20),
                      buildPointsCard(),
                      // Only show parent alert if flagged
                      if (result.safetyFlag == SafetyFlag.flagForParent) ...[
                        const SizedBox(height: 20),
                        buildParentAlert(),
                      ],
                      const SizedBox(height: 20),
                      buildOriginalClaim(),
                      const SizedBox(height: 30),
                      buildBackButton(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Back arrow and title
  Widget buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Text(
            'Your Result',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Big verdict card with emoji and truth meter
  Widget buildVerdictCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white30, width: 2),
      ),
      child: Column(
        children: [
          Text(verdictEmoji, style: const TextStyle(fontSize: 70)),
          const SizedBox(height: 14),
          Text(
            verdictLabel,
            style: GoogleFonts.nunito(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          TruthMeter(verdict: result.verdict),
        ],
      ),
    );
  }

  // Card showing Trek's explanation
  Widget buildExplanationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'Trek says:',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C3AE8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.kidExplanation,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: const Color(0xFF2D2D2D),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // Yellow card showing points earned
  Widget buildPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD600),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Column(
            children: [
              Text(
                '+${result.pointsAwarded} Points!',
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF3A1A8A),
                ),
              ),
              Text(
                'Truth Explorer Points Earned!',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: const Color(0xFF3A1A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Red alert box shown only when safety agent flagged the content
  Widget buildParentAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚨', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                'Parent Alert!',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'This content has been flagged. '
            'Please show this screen to a trusted adult before doing anything!',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.red,
              height: 1.5,
            ),
          ),
          if (result.safetyReason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reason: ${result.safetyReason}',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.redAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Shows the original claim the child typed
  Widget buildOriginalClaim() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You submitted:',
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"${result.originalClaim}"',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Back button at the bottom
  Widget buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD600),
          foregroundColor: const Color(0xFF3A1A8A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Check Another Claim! 🔍',
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}