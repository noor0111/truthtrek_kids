// agent_pipeline.dart
// This file runs all 3 agents one after another.
// Think of it like an assembly line:
// Agent 1 checks the claim → Agent 2 explains it → Agent 3 checks safety
// At the end we get one complete ClaimResult object.

import '../models/claim_result.dart';
import 'claim_check_agent.dart';
import 'explainer_agent.dart';
import 'safety_agent.dart';

class AgentPipeline {

  // Create one instance of each agent
  final ClaimCheckAgent _claimChecker = ClaimCheckAgent();
  final ExplainerAgent _explainer = ExplainerAgent();
  final SafetyAgent _safetyAgent = SafetyAgent();

  // onStatusUpdate is a function the UI calls to show progress messages
  // For example: "Checking facts..." then "Writing explanation..."
  final void Function(String message)? onStatusUpdate;

  // Constructor
  AgentPipeline({this.onStatusUpdate});

  // run() is the main function — it takes the claim and runs all 3 agents
  Future<ClaimResult> run(String claim) async {

    // ── AGENT 1: Check if the claim is true or false ──────────────
    onStatusUpdate?.call('🔍 Checking if this is true or false...');

    // Call Agent 1 and store its result in a Map
    Map<String, dynamic> checkResult = await _claimChecker.analyze(claim);

    // Pull out the values from the Map
    String verdict = checkResult['verdict'] ?? 'NEEDS_VERIFICATION';
    String reason  = checkResult['reason']  ?? '';
    int points     = checkResult['points']  ?? 5;


    // ── AGENT 2: Rewrite the verdict in simple language ───────────
    onStatusUpdate?.call('✏️ Writing the explanation for you...');

    // Call Agent 2 with the verdict from Agent 1
    Map<String, dynamic> explainResult = await _explainer.explain(
      originalClaim: claim,
      verdict: verdict,
      reason: reason,
    );

    // Pull out the values
    String headline    = explainResult['headline']    ?? '';
    String explanation = explainResult['explanation'] ?? '';
    String tip         = explainResult['tip']         ?? '';


    // ── AGENT 3: Check if content is safe for the child ──────────
    onStatusUpdate?.call('🛡️ Checking if this is safe for you...');

    // Call Agent 3
    Map<String, dynamic> safetyResult = await _safetyAgent.evaluate(
      originalClaim: claim,
      verdict: verdict,
    );

    // Pull out the values
    bool flagForParent = safetyResult['flagForParent'] ?? false;
    String safetyReason = safetyResult['reason'] ?? '';


    // ── BUILD THE FINAL RESULT ────────────────────────────────────
    onStatusUpdate?.call('✅ Done! Here is your result!');

    // Convert the verdict string into a Verdict enum value
    Verdict verdictEnum;
    if (verdict == 'TRUE') {
      verdictEnum = Verdict.tru;
    } else if (verdict == 'MISLEADING') {
      verdictEnum = Verdict.misleading;
    } else {
      verdictEnum = Verdict.needsVerification;
    }

    // Convert the safety flag into a SafetyFlag enum value
    SafetyFlag safetyFlagEnum;
    if (flagForParent) {
      safetyFlagEnum = SafetyFlag.flagForParent;
    } else {
      safetyFlagEnum = SafetyFlag.safe;
    }

    // Combine headline + explanation + tip into one full explanation
    String fullExplanation = '$headline\n\n$explanation\n\n💡 Tip: $tip';

    // Create and return the final ClaimResult object
    return ClaimResult(
      id: '',                        // Firestore will assign a real ID later
      originalClaim: claim,
      verdict: verdictEnum,
      kidExplanation: fullExplanation,
      safetyFlag: safetyFlagEnum,
      safetyReason: flagForParent ? safetyReason : '',
      pointsAwarded: points,
      timestamp: DateTime.now(),
    );
  }
}