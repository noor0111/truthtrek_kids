// claim_check_agent.dart
// This is Agent 1. It sends the claim to Gemini AI and asks:
// "Is this TRUE, MISLEADING, or does it NEED VERIFICATION?"

import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';

class ClaimCheckAgent {

  // This function takes a claim (text) and returns a Map with the result
  Future<Map<String, dynamic>> analyze(String claim) async {

    // Step 1: Connect to Gemini AI using our API key
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
    );

    // Step 2: Write the instructions for Gemini
    // We tell it exactly what format to reply in
    final String instructions = '''
You are a fact-checking helper for Pakistani children under 15.
You check if a claim is true or false.
You understand Pakistani context like WhatsApp forwards, 
cricket facts, and local health myths.

Always reply with ONLY this format, nothing else:
VERDICT: TRUE or MISLEADING or NEEDS_VERIFICATION
REASON: one simple sentence why
POINTS: 10 or 5 or 3

Rules:
- TRUE = give 10 points
- MISLEADING = give 10 points  
- NEEDS_VERIFICATION = give 5 points
''';

    // Step 3: Build the full message to send to Gemini
    final String message = '''
$instructions

Check this claim: "$claim"
''';

    try {
      // Step 4: Send the message to Gemini and wait for reply
      GenerateContentResponse? response;
for (int i = 0; i < 3; i++) {
  try {
    response = await model.generateContent([
      Content.text(message),
    ]);
    break;
  } catch (e) {
    if (i == 2) rethrow;
    await Future.delayed(Duration(seconds: 2));
  }
}
      // Step 5: Get the text from the reply
      final String replyText = response?.text ?? '';

       print('RAW GEMINI RESPONSE:');
      print(replyText);

      // Step 6: Read the reply line by line and extract the values
      String verdict = 'NEEDS_VERIFICATION';
      String reason = 'Could not analyze this. Ask a trusted adult!';
      int points = 5;

      // Split the reply into separate lines
      List<String> lines = replyText.split('\n');

      for (String line in lines) {
        // Check each line for VERDICT, REASON, POINTS
        if (line.startsWith('VERDICT:')) {
          verdict = line.replaceAll('VERDICT:', '').trim();
        }
        if (line.startsWith('REASON:')) {
          reason = line.replaceAll('REASON:', '').trim();
        }
        if (line.startsWith('POINTS:')) {
          String pointsText = line.replaceAll('POINTS:', '').trim();
          points = int.tryParse(pointsText) ?? 5;
        }
      }

      // Step 7: Return the result as a Map
      return {
        'verdict': verdict,
        'reason': reason,
        'points': points,
      };

    } catch (e) {
      // If something goes wrong, return a safe default answer
      print('ClaimCheckAgent FULL ERROR:');
print(e.toString());
      return {
        'verdict': 'NEEDS_VERIFICATION',
        'reason': 'Could not check this right now. Ask a trusted adult!',
        'points': 3,
      };
    }
  }
}