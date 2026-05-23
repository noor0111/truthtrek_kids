// explainer_agent.dart
// This is Agent 2. It takes the verdict from Agent 1 and
// rewrites it in simple, fun language for children.

import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';

class ExplainerAgent {

  // This function takes the verdict and returns a simple explanation
  Future<Map<String, dynamic>> explain({
    required String originalClaim,
    required String verdict,
    required String reason,
  }) async {

    // Step 1: Connect to Gemini AI
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
    );

    // Step 2: Write instructions telling Gemini to talk like a friendly helper
    final String instructions = '''
You are "Trek", a friendly AI helper talking to a Pakistani child under 15.
Use simple English. Short sentences. Fun emojis.
Sometimes use friendly words like "Dear" or "thanks".
Never make the child feel bad.

Always reply with ONLY this format, nothing else:
HEADLINE: short fun summary with emoji (max 7 words)
EXPLANATION: 2 simple sentences explaining what this means
TIP: one practical tip the child can use next time
''';

    // Step 3: Build the message
    final String message = '''
$instructions

The child submitted: "$originalClaim"
The verdict is: $verdict
The reason is: $reason

Now explain this to the child in a fun and simple way.
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

      // Step 5: Read the reply and extract headline, explanation, tip
      String headline = 'Let me explain! 🤔';
      String explanation = 'This claim needed checking. Always ask an adult!';
      String tip = 'Before sharing on WhatsApp, always verify first!';

      List<String> lines = replyText.split('\n');

      for (String line in lines) {
        if (line.startsWith('HEADLINE:')) {
          headline = line.replaceAll('HEADLINE:', '').trim();
        }
        if (line.startsWith('EXPLANATION:')) {
          explanation = line.replaceAll('EXPLANATION:', '').trim();
        }
        if (line.startsWith('TIP:')) {
          tip = line.replaceAll('TIP:', '').trim();
        }
      }

      // Step 6: Return the result
      return {
        'headline': headline,
        'explanation': explanation,
        'tip': tip,
      };

    } catch (e) {
      // If something goes wrong, return a simple default message
      print('ExplainerAgent FULL ERROR:');
print(e.toString());

      // Give a different default message depending on verdict
      if (verdict == 'TRUE') {
        return {
          'headline': '✅ This is TRUE!',
          'explanation': 'Yaar, this one is actually correct! Good job checking it.',
          'tip': 'Keep learning real facts — they make you super smart!',
        };
      } else if (verdict == 'MISLEADING') {
        return {
          'headline': '⚠️ This is MISLEADING!',
          'explanation': 'This is not fully true. Someone may be trying to confuse people.',
          'tip': 'If something sounds too amazing or scary, check it first!',
        };
      } else {
        return {
          'headline': '🔍 Needs Checking!',
          'explanation': 'We are not sure about this one. Always verify before sharing!',
          'tip': 'Ask a parent or teacher, or check BBC Urdu!',
        };
      }
    }
  }
}