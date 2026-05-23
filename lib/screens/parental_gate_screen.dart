import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class ParentalGateScreen extends StatefulWidget {
  const ParentalGateScreen({super.key});
  @override
  State<ParentalGateScreen> createState() => _ParentalGateScreenState();
}

class _ParentalGateScreenState extends State<ParentalGateScreen> {
  bool showMathGate = false;
  final TextEditingController answerController = TextEditingController();
  bool wrongAnswer = false;
  final int num1 = 17;
  final int num2 = 8;
  int get correctAnswer => num1 + num2;

  void checkAnswer() {
    final int? typed = int.tryParse(answerController.text.trim());
    if (typed == correctAnswer) {
      saveDisclaimerSeen();
    } else {
      setState(() => wrongAnswer = true);
      answerController.clear();
    }
  }

  Future<void> saveDisclaimerSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_disclaimer', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3D2B1F), // dark brown
              Color(0xFF6B4226), // medium brown
            ],
          ),
        ),
        child: SafeArea(
          child: showMathGate ? buildMathGate() : buildDisclaimer(),
        ),
      ),
    );
  }

  Widget buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 70)),
          const SizedBox(height: 24),
          Text('Hello, Parents! 👋',
              style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Column(
              children: [
                Text('🤖 This app uses AI — not a real person.',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4A017)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 14),
                Text(
                    'TruthTrek Kids uses Artificial Intelligence to help '
                    'children spot fake news. '
                    'No personal information is collected. '
                    'Your child signs in anonymously. '
                    'You can delete all data from the Parent Dashboard.',
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.6),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => showMathGate = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A017), // gold
                foregroundColor: const Color(0xFF2C1A0E), // dark brown
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('I am a Parent — Continue',
                  style: GoogleFonts.nunito(
                      fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMathGate() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔐 Parent Check',
              style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 10),
          Text('Please answer to confirm you are an adult:',
              style: GoogleFonts.nunito(
                  fontSize: 15, color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('What is $num1 + $num2 = ?',
                    style: GoogleFonts.nunito(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD4A017))),
                const SizedBox(height: 20),
                TextField(
                  controller: answerController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '?',
                    hintStyle:
                        const TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: wrongAnswer
                              ? Colors.red
                              : Colors.white30,
                          width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFD4A017), width: 2),
                    ),
                  ),
                ),
                if (wrongAnswer) ...[
                  const SizedBox(height: 10),
                  Text('That is not right. Try again!',
                      style: GoogleFonts.nunito(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A017), // gold
                foregroundColor: const Color(0xFF2C1A0E), // dark brown
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Check My Answer',
                  style: GoogleFonts.nunito(
                      fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }
}