// privacy_policy_screen.dart
// Simple privacy policy screen required for COPPA compliance.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF3A1A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TruthTrek Kids Privacy Policy',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3A1A8A),
              ),
            ),
            const SizedBox(height: 20),
            buildSection('What We Collect',
                'We collect nothing personally identifiable. '
                'No name, no email, no phone number. '
                'Your child signs in with a random anonymous ID.'),
            buildSection('How We Use AI',
                'We use Google Gemini AI to analyze claims. '
                'No claim text is stored by Google for training.'),
            buildSection('Data Storage',
                'Results and points are stored in Firebase Firestore '
                'under an anonymous user ID only.'),
            buildSection('Parental Rights',
                'You can delete ALL data at any time from the Parent Dashboard. '
                'Deletion is immediate and permanent.'),
            buildSection('COPPA Compliance',
                'This app is designed for children under 15 '
                'with full COPPA compliance. '
                'No personal information is collected from children.'),
          ],
        ),
      ),
    );
  }

  // Helper function to build each section
  Widget buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C3AE8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF2D2D2D),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}