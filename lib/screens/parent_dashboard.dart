// parent_dashboard.dart
// Parents can see what their child checked and delete all data.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/claim_result.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'parental_gate_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {

  List<ClaimResult> history = [];
  int totalPoints = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();

    if (auth.userId != null) {
      final data = await firestore.getClaimHistory(auth.userId!);
      final pts = await firestore.getTotalPoints(auth.userId!);
      if (mounted) {
        setState(() {
          history = data;
          totalPoints = pts;
          isLoading = false;
        });
      }
    }
  }

  // Called when parent presses Delete All Data button
  Future<void> deleteAllData() async {
    // Show a confirmation dialog first
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🗑️ Delete Everything?',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This will permanently delete all history, points, and the account. '
          'This cannot be undone.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete All',
              style: GoogleFonts.nunito(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // If parent did not confirm, do nothing
    if (confirmed != true) return;

    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();

    try {
      // Delete all Firestore data
      if (auth.userId != null) {
        await firestore.deleteAllUserData(auth.userId!);
      }
      // Delete the Firebase Auth account
      await auth.deleteAccount();

      // Go back to parental gate screen
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ParentalGateScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deletion failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String verdictText(Verdict v) {
    if (v == Verdict.tru) return '✅ TRUE';
    if (v == Verdict.misleading) return '⚠️ MISLEADING';
    return '🔍 NEEDS CHECK';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF3A1A8A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Text(
                      '🛡️ Parent Dashboard',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD600),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [

                            // Stats card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '⭐ $totalPoints Total Points',
                                    style: GoogleFonts.nunito(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFFFD600),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${history.length} claims checked total',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '🚨 ${history.where((c) => c.safetyFlag == SafetyFlag.flagForParent).length} flagged for your attention',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // AI disclaimer for parents
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                '🤖 This app uses AI for educational purposes only. '
                                'AI may not always be 100% accurate. '
                                'Please discuss any flagged content with your child.',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Flagged items section
                            if (history.any((c) => c.safetyFlag == SafetyFlag.flagForParent)) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '🚨 Flagged Content',
                                  style: GoogleFonts.nunito(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...history
                                  .where((c) => c.safetyFlag == SafetyFlag.flagForParent)
                                  .map((item) => Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.red),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '"${item.originalClaim}"',
                                              style: GoogleFonts.nunito(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Verdict: ${verdictText(item.verdict)}',
                                              style: GoogleFonts.nunito(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            if (item.safetyReason.isNotEmpty)
                                              Text(
                                                'Reason: ${item.safetyReason}',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 12,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )),
                              const SizedBox(height: 10),
                            ],

                            // All claims list
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '📋 All Checked Claims',
                                style: GoogleFonts.nunito(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...history.map((item) => Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '"${item.originalClaim}" → ${verdictText(item.verdict)}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),

                            const SizedBox(height: 30),

                            // Delete button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: deleteAllData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  '🗑️ Delete Account & All Data',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
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
}