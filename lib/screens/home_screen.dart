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
  final TextEditingController textController = TextEditingController();
  bool isLoading = false;
  String statusMessage = '';
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  Future<void> loadPoints() async {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    if (auth.userId != null) {
      final pts = await firestore.getTotalPoints(auth.userId!);
      if (mounted) setState(() => totalPoints = pts);
    }
  }

  Future<void> submitClaim() async {
    final String claim = textController.text.trim();
    if (claim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please type something first! 😊',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6B4226),
      ));
      return;
    }
    if (claim.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please type a bit more! ✍️',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6B4226),
      ));
      return;
    }
    setState(() {
      isLoading = true;
      statusMessage = '🤔 Starting analysis...';
    });
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    try {
      final pipeline = AgentPipeline(
        onStatusUpdate: (message) {
          if (mounted) setState(() => statusMessage = message);
        },
      );
      final result = await pipeline.run(claim);
      await firestore.saveClaim(auth.userId!, result);
      await firestore.addPoints(auth.userId!, result.pointsAwarded);
      final newPoints = await firestore.getTotalPoints(auth.userId!);
      if (!mounted) return;
      setState(() {
        totalPoints = newPoints;
        isLoading = false;
      });
      textController.clear();
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        statusMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong. Try again! 🔄',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3D2B1F), // dark brown top
              Color(0xFF6B4226), // medium brown middle
              Color(0xFFA0522D), // warm brown bottom
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

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🧭', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text('TruthTrek',
                  style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
          Row(
            children: [
              PointsBadge(points: totalPoints),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF3D2B1F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'history') {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const HistoryScreen()))
                        .then((_) => loadPoints());
                  } else if (value == 'parent') {
                    Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ParentDashboard()))
                        .then((_) => loadPoints());
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'history',
                    child: Row(children: [
                      const Icon(Icons.history, color: Color(0xFFD4A017)),
                      const SizedBox(width: 8),
                      Text('My History',
                          style: GoogleFonts.nunito(color: Colors.white)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'parent',
                    child: Row(children: [
                      const Icon(Icons.shield, color: Color(0xFFD4A017)),
                      const SizedBox(width: 8),
                      Text('Parent Dashboard',
                          style: GoogleFonts.nunito(color: Colors.white)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHeroSection() {
    return Column(
      children: [
        const Text('🕵️', style: TextStyle(fontSize: 70)),
        const SizedBox(height: 14),
        Text('Is It TRUE or FALSE?',
            style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Type any claim, WhatsApp message,\nor thing you read online!',
            style: GoogleFonts.nunito(
                fontSize: 15, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5DEB3), // beige card
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: textController,
            maxLines: 4,
            maxLength: 500,
            enabled: !isLoading,
            style: GoogleFonts.nunito(
                fontSize: 15, color: const Color(0xFF3D2B1F)),
            decoration: InputDecoration(
              hintText:
                  'Type something here...\ne.g. "Eating neem leaves cures all diseases"',
              hintStyle:
                  GoogleFonts.nunito(color: Colors.grey, fontSize: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFD4A017))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFD4A017), width: 2)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFA0522D), width: 2)),
              filled: true,
              fillColor: const Color(0xFFFFF8EE), // light cream
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : submitClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA0522D), // warm brown
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                                color: Colors.white)),
                        const SizedBox(width: 12),
                        Text('Analyzing...',
                            style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍',
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text('CHECK THIS CLAIM!',
                            style: GoogleFonts.nunito(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

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
                  strokeWidth: 3, color: Color(0xFFD4A017))),
          const SizedBox(width: 14),
          Expanded(
            child: Text(statusMessage,
                style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget buildSampleClaims() {
    final List<String> samples = [
      '🌿 Eating neem leaves cures all diseases',
      '🏏 Pakistan won the 1992 Cricket World Cup',
      '🎁 A stranger online wants to give me a prize',
      '🏫 School is cancelled tomorrow (WhatsApp forward)',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('💡 Try these examples:',
            style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white70)),
        const SizedBox(height: 10),
        ...samples.map((sample) {
          return GestureDetector(
            onTap: () =>
                textController.text = sample.substring(2).trim(),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(sample,
                  style: GoogleFonts.nunito(
                      fontSize: 14, color: Colors.white)),
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