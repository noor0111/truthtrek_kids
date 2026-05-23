// home_screen.dart
// This is the main screen the child uses every day.
// It has a text box to type a claim and a big CHECK button.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../agents/agent_pipeline.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/points_badge.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'parent_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Controller reads what the child types in the text box
  final TextEditingController textController = TextEditingController();

  // isLoading = true when the agents are running
  bool isLoading = false;

  // statusMessage shows what the agent is currently doing
  String statusMessage = '';

  // totalPoints shows the child's current score
  int totalPoints = 0;

  // Called once when this screen first appears
  @override
  void initState() {
    super.initState();
    loadPoints(); // load points from database
  }

  // Loads the child's points from Firestore
  Future<void> loadPoints() async {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();

    if (auth.userId != null) {
      final pts = await firestore.getTotalPoints(auth.userId!);
      if (mounted) {
        setState(() {
          totalPoints = pts;
        });
      }
    }
  }

  // Called when the child presses the CHECK button
  Future<void> submitClaim() async {
    // Get whatever the child typed
    final String claim = textController.text.trim();

    // Don't do anything if the box is empty
    if (claim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please type something first! 😊',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF6C3AE8),
        ),
      );
      return;
    }

    // Don't do anything if text is too short
    if (claim.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please type a bit more! ✍️',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF6C3AE8),
        ),
      );
      return;
    }

    // Show loading spinner
    setState(() {
      isLoading = true;
      statusMessage = '🤔 Starting analysis...';
    });

    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();

    try {
      // Create the pipeline and run all 3 agents
      final pipeline = AgentPipeline(
        onStatusUpdate: (message) {
          // Update the status message shown on screen
          if (mounted) {
            setState(() {
              statusMessage = message;
            });
          }
        },
      );

      // Run the pipeline — this calls all 3 agents
      final result = await pipeline.run(claim);

      // Save the result to Firestore
      await firestore.saveClaim(auth.userId!, result);

      // Add the points to the user's total
      await firestore.addPoints(auth.userId!, result.pointsAwarded);

      // Reload the points display
      final newPoints = await firestore.getTotalPoints(auth.userId!);

      if (!mounted) return;

      // Update points on screen
      setState(() {
        totalPoints = newPoints;
        isLoading = false;
      });

      // Clear the text box
      textController.clear();

      // Go to the result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );

    } catch (e) {
      // If something went wrong, stop loading and show error
      if (!mounted) return;
      setState(() {
        isLoading = false;
        statusMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong. Try again! 🔄',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Purple gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A1A8A),
              Color(0xFF6C3AE8),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      buildHeroSection(),
                      const SizedBox(height: 24),
                      buildInputCard(),
                      const SizedBox(height: 16),
                      if (isLoading) buildLoadingBox(),
                      const SizedBox(height: 20),
                      buildSampleClaims(),
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

  // ── HEADER with logo and points ───────────────────────────────
  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App name
          Row(
            children: [
              const Text('🧭', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                'TruthTrek',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Points badge and menu button
          Row(
            children: [
              PointsBadge(points: totalPoints),
              const SizedBox(width: 10),

              // Three dot menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF3A1A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'history') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
                      ),
                    ).then((_) => loadPoints());
                  } else if (value == 'parent') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentDashboard(),
                      ),
                    ).then((_) => loadPoints());
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Color(0xFFFFD600)),
                        const SizedBox(width: 8),
                        Text(
                          'My History',
                          style: GoogleFonts.nunito(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'parent',
                    child: Row(
                      children: [
                        const Icon(Icons.shield, color: Color(0xFFFFD600)),
                        const SizedBox(width: 8),
                        Text(
                          'Parent Dashboard',
                          style: GoogleFonts.nunito(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── HERO SECTION with emoji and title ────────────────────────
  Widget buildHeroSection() {
    return Column(
      children: [
        const Text('🕵️', style: TextStyle(fontSize: 70)),
        const SizedBox(height: 14),
        Text(
          'Is It TRUE or FALSE?',
          style: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Type any claim, WhatsApp message,\nor thing you read online!',
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── INPUT CARD with text box and button ───────────────────────
  Widget buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Text input box
          TextField(
            controller: textController,
            maxLines: 4,
            maxLength: 500,
            enabled: !isLoading, // disable while loading
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: const Color(0xFF3A1A8A),
            ),
            decoration: InputDecoration(
              hintText: 'Type something here...\ne.g. "Eating neem leaves cures all diseases"',
              hintStyle: GoogleFonts.nunito(
                color: Colors.grey,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE0D5FF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE0D5FF),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF6C3AE8),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F0FF),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),

          // Check button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : submitClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C3AE8),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Analyzing...',
                          style: GoogleFonts.nunito(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(
                          'CHECK THIS CLAIM!',
                          style: GoogleFonts.nunito(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LOADING BOX shows agent status messages ───────────────────
  Widget buildLoadingBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFFFFD600),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              statusMessage,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SAMPLE CLAIMS the child can tap to try ───────────────────
  Widget buildSampleClaims() {
    // List of example claims
    final List<String> samples = [
      '🌿 Eating neem leaves cures all diseases',
      '🏏 Pakistan won the 1992 Cricket World Cup',
      '🎁 A stranger online wants to give me a prize',
      '🏫 School is cancelled tomorrow (WhatsApp forward)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Try these examples:',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),

        // Build one button for each sample
        ...samples.map((sample) {
          return GestureDetector(
            onTap: () {
              // Remove the emoji from the start when tapping
              textController.text = sample.substring(2).trim();
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                sample,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}