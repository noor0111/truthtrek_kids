// main.dart
// This is the starting point of the whole app.
// It sets up Firebase, signs in anonymously, and shows the first screen.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/home_screen.dart';
import 'screens/parental_gate_screen.dart';

// main() is the very first function that runs when the app starts
Future<void> main() async {
  // Make sure Flutter is ready before we do anything
  WidgetsFlutterBinding.ensureInitialized();

  // Start Firebase using the settings from firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Sign in anonymously if not already signed in
  final AuthService authService = AuthService();
  if (!authService.isSignedIn) {
    await authService.signInAnonymously();
  }

  // Check if the parent has already seen the disclaimer
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool seenDisclaimer = false;
  // Start the app and pass seenDisclaimer to it
  runApp(TruthTrekApp(seenDisclaimer: seenDisclaimer));
}

// TruthTrekApp is the root widget of the entire app
class TruthTrekApp extends StatelessWidget {
  final bool seenDisclaimer;

  // Constructor
  const TruthTrekApp({super.key, required this.seenDisclaimer});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Provider makes AuthService and FirestoreService available everywhere
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'TruthTrek Kids',
        debugShowCheckedModeBanner: false,

        // App colors and fonts
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C3AE8),
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
          useMaterial3: true,
        ),

        // If parent already saw disclaimer go to Home, otherwise show Gate
        home: seenDisclaimer
            ? HomeScreen()
            : ParentalGateScreen(),
      ),
    );
  }
}