// history_screen.dart
// Shows the child's last 20 checked claims with colored verdict badges.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/claim_result.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  // List to store the claim history
  List<ClaimResult> history = [];

  // true while loading from database
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // Loads claim history from Firestore
  Future<void> loadHistory() async {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();

    if (auth.userId != null) {
      final data = await firestore.getClaimHistory(auth.userId!);
      if (mounted) {
        setState(() {
          history = data;
          isLoading = false;
        });
      }
    }
  }

  // Returns color for each verdict
  Color verdictColor(Verdict v) {
    if (v == Verdict.tru) return const Color(0xFF2ECC71);
    if (v == Verdict.misleading) return const Color(0xFFE74C3C);
    return const Color(0xFFFFD600);
  }

  // Returns label text for each verdict
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
            colors: [Color(0xFF3A1A8A), Color(0xFF6C3AE8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Text(
                      'My Claim History',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD600),
                        ),
                      )
                    : history.isEmpty
                        ? Center(
                            child: Text(
                              'No claims checked yet!\nGo explore! 🕵️',
                              style: GoogleFonts.nunito(
                                fontSize: 17,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final item = history[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Claim text
                                          Text(
                                            item.originalClaim,
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2D2D2D),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              // Verdict badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: verdictColor(item.verdict)
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  verdictText(item.verdict),
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: verdictColor(item.verdict),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Points earned
                                              Text(
                                                '+${item.pointsAwarded} pts',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 12,
                                                  color: const Color(0xFF6C3AE8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Show warning emoji if flagged
                                    if (item.safetyFlag == SafetyFlag.flagForParent)
                                      const Text('🚨', style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}