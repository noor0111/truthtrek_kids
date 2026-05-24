# TruthTrek Kids 🧭

This is our AI lab semester project at SZABIST. We built a fact-checking 
app for Pakistani kids under 15. The main idea came from how much fake news 
and misleading WhatsApp forwards kids see every day in Pakistan and how they 
have no way to verify if something is actually true or not.


## What the app does

You open the app, type any claim or message you saw online or received on 
WhatsApp, and the app tells you if it is TRUE, MISLEADING, or needs more 
checking. It also explains the result in simple language with emojis so 
kids can actually understand it. If something looks dangerous like a stranger 
offering free prizes or asking for personal info, the app flags it and shows 
a warning for the parent.

Kids also earn points every time they check a claim which makes it feel 
more like a game than a homework assignment.


## The AI part — 3 agents working together

Instead of just calling one AI and showing the result, we built three 
separate agents that each do a specific job:

**Agent 1 — Claim Check Agent**
This one actually reads the claim and decides if it is true, misleading, 
or uncertain. It also assigns points based on how the claim turned out.

**Agent 2 — Explainer Agent (Trek)**
This one takes the verdict from Agent 1 and rewrites it in simple friendly 
language that a child under 15 can understand. It uses emojis and sometimes 
friendly words like to make it feel approachable.

**Agent 3 — Safety Agent**
This one checks if the content could be harmful for a child. Things like 
strangers offering gifts, health myths that could be dangerous, or requests 
for personal information. If it finds something concerning it flags it for 
the parent to see.

All three agents run one after another automatically without any manual 
steps in between. This is what makes it an agentic workflow.


## Tech we used

- Flutter and Dart for building the app
- Firebase Firestore for storing claim history and points
- Firebase Anonymous Authentication so no personal data is needed
- Google Gemini 2.5 Flash for the AI agents
- Provider for state management
- Google Fonts Nunito for the typography

---

## Child safety and COPPA compliance

Since this app is made for children we had to be very careful about privacy:

- No personal information is collected at all
- The login is completely anonymous — Firebase just creates a random ID
- When you first open the app a parent has to read a disclaimer and 
  answer a simple math question to confirm an adult has seen it
- Parents can open the Parent Dashboard and see every single claim 
  their child has checked
- There is a delete button that permanently removes all data and 
  the account in one click

---

## Project structure
lib/
├── agents/
│   ├── claim_check_agent.dart
│   ├── explainer_agent.dart
│   ├── safety_agent.dart
│   └── agent_pipeline.dart
├── models/
│   └── claim_result.dart
├── screens/
│   ├── home_screen.dart
│   ├── result_screen.dart
│   ├── history_screen.dart
│   ├── parent_dashboard.dart
│   ├── parental_gate_screen.dart
│   └── privacy_policy_screen.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
├── widgets/
│   ├── points_badge.dart
│   └── truth_meter.dart
├── config.dart
└── main.dart

---

## How to run it yourself

1. Clone this repo
2. Run `flutter pub get`
3. Create a file at `lib/config.dart` and add your Gemini API key:

```dart
class AppConfig {
  static const String geminiApiKey = 'your key here';
}
```

4. Set up your own Firebase project and replace `firebase_options.dart`
5. Run `flutter run`

---

## Sample claims to test

These are some good ones to try when testing the app:

- Karachi tap water causes cancer (WhatsApp forward)
- Pakistan has won the most Cricket World Cups
- Someone on PUBG is offering me free diamonds
- SZABIST has announced holiday tomorrow

---

## About this project

SZABIST University Karachi
BS Computer Science — Semester 6
Artificial Intelligence Lab — CSCL-4101
Spring 2026