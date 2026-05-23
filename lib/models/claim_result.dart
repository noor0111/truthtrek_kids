// claim_result.dart
// This file describes what a "claim result" looks like.
// Every time a child checks a claim, one ClaimResult is created.

// Verdict tells us if the claim is true, fake, or needs checking
enum Verdict {
  tru,               // The claim is TRUE
  misleading,        // The claim is MISLEADING (fake or exaggerated)
  needsVerification  // We are NOT SURE — needs more checking
}

// SafetyFlag tells us if a parent needs to see this
enum SafetyFlag {
  safe,          // Content is fine for the child
  flagForParent  // Parent should be told about this
}

// ClaimResult holds all information about one checked claim
class ClaimResult {
  final String id;              // Unique ID from Firestore
  final String originalClaim;   // What the child typed
  final Verdict verdict;        // TRUE / MISLEADING / NEEDS_VERIFICATION
  final String kidExplanation;  // Simple explanation for the child
  final SafetyFlag safetyFlag;  // Safe or needs parent
  final String safetyReason;    // Why it was flagged (if it was)
  final int pointsAwarded;      // Points the child earns
  final DateTime timestamp;     // When this was checked

  // Constructor — used when creating a new ClaimResult
  ClaimResult({
    required this.id,
    required this.originalClaim,
    required this.verdict,
    required this.kidExplanation,
    required this.safetyFlag,
    required this.safetyReason,
    required this.pointsAwarded,
    required this.timestamp,
  });

  // toMap — converts this object into a Map so we can save it to Firestore
  Map<String, dynamic> toMap() {
    return {
      'originalClaim': originalClaim,
      'verdict': verdict.name,
      'kidExplanation': kidExplanation,
      'safetyFlag': safetyFlag.name,
      'safetyReason': safetyReason,
      'pointsAwarded': pointsAwarded,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // fromMap — converts a Firestore Map back into a ClaimResult object
  factory ClaimResult.fromMap(String id, Map<String, dynamic> map) {
    return ClaimResult(
      id: id,
      originalClaim: map['originalClaim'] ?? '',
      verdict: Verdict.values.firstWhere(
        (v) => v.name == map['verdict'],
        orElse: () => Verdict.needsVerification,
      ),
      kidExplanation: map['kidExplanation'] ?? '',
      safetyFlag: SafetyFlag.values.firstWhere(
        (s) => s.name == map['safetyFlag'],
        orElse: () => SafetyFlag.safe,
      ),
      safetyReason: map['safetyReason'] ?? '',
      pointsAwarded: map['pointsAwarded'] ?? 0,
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}