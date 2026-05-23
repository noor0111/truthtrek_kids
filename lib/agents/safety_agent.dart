// safety_agent.dart
// This is Agent 3. It checks if the content is safe for the child.
// If not, it sets a flag so the Parent Dashboard shows a warning.

import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';

class SafetyAgent {

  // This function checks if the claim has any safety risks for a child
  Future<Map<String, dynamic>> evaluate({
    required String originalClaim,
    required String verdict,
  }) async {

    // Step 1: Connect to Gemini AI
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
    );

    // Step 2: Write instructions for the safety check
    final String instructions = '''
You are a child safety checker for Pakistani children under 15.
You decide if content is dangerous for a child.

FLAG as unsafe if the content involves:
- A stranger offering prizes, gifts, or money
- Requests to click unknown links
- Asking for personal info like address or school name
- Violence or self-harm
- Health claims that could physically hurt someone if followed

DO NOT FLAG if the content is:
- A general knowledge or school fact
- Sports news
- A normal WhatsApp forward about food or weather

Always reply with ONLY this format, nothing else:
FLAG: true or false
RISK: NONE or LOW or HIGH
REASON: one sentence explaining your decision
''';

    // Step 3: Build the message
    final String message = '''
$instructions

The child submitted: "$originalClaim"
The fact-check verdict was: $verdict

Is this content safe for the child?
''';

    try {
      // Step 4: Send to Gemini and wait for reply
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

      final String replyText = response?.text ?? '';
      print('RAW GEMINI RESPONSE:');
print(replyText);

      // Step 5: Read the reply and extract FLAG, RISK, REASON
      bool flagForParent = false;
      String risk = 'NONE';
      String reason = 'Content is safe.';

      List<String> lines = replyText.split('\n');

      for (String line in lines) {
        if (line.startsWith('FLAG:')) {
          String flagText = line.replaceAll('FLAG:', '').trim().toLowerCase();
          // If Gemini said "true", set flagForParent to true
          flagForParent = (flagText == 'true');
        }
        if (line.startsWith('RISK:')) {
          risk = line.replaceAll('RISK:', '').trim();
        }
        if (line.startsWith('REASON:')) {
          reason = line.replaceAll('REASON:', '').trim();
        }
      }

      // Step 6: Return the result
      return {
        'flagForParent': flagForParent,
        'risk': risk,
        'reason': reason,
      };

    } catch (e) {
      // If something goes wrong, default to safe (don't want false alarms)
      print('SafetyAgent FULL ERROR:');
print(e.toString());
      return {
        'flagForParent': false,
        'risk': 'NONE',
        'reason': 'Could not check safety. Please ask an adult.',
      };
    }
  }
}