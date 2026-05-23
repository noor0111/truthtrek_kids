// firestore_service.dart
// This service saves data to BOTH local SQLite AND Firebase Firestore.
// SQLite = main storage (works offline)
// Firestore = cloud backup (satisfies Firebase requirement)

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/claim_result.dart';

class FirestoreService {

  // Local SQLite database connection
  Database? _db;

  // Cloud Firestore connection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Opens local SQLite database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'truthtrek.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE claims(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT,
            originalClaim TEXT,
            verdict TEXT,
            kidExplanation TEXT,
            safetyFlag TEXT,
            safetyReason TEXT,
            pointsAwarded INTEGER,
            timestamp TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE points(
            userId TEXT PRIMARY KEY,
            totalPoints INTEGER
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }

  // Saves claim to SQLite (main) and Firestore (cloud backup)
  Future<String> saveClaim(String userId, ClaimResult result) async {
    // Save to local SQLite first
    final db = await database;
    final id = await db.insert('claims', {
      'userId': userId,
      'originalClaim': result.originalClaim,
      'verdict': result.verdict.name,
      'kidExplanation': result.kidExplanation,
      'safetyFlag': result.safetyFlag.name,
      'safetyReason': result.safetyReason,
      'pointsAwarded': result.pointsAwarded,
      'timestamp': result.timestamp.toIso8601String(),
    });

    // Also save to Firestore cloud (for Firebase requirement)
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('claims')
          .add(result.toMap());
    } catch (e) {
      // If cloud save fails, local save already succeeded so no problem
      print('Firestore cloud save failed (offline?): $e');
    }

    return id.toString();
  }

  // Loads claim history from local SQLite
  Future<List<ClaimResult>> getClaimHistory(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'claims',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 20,
    );

    return maps.map((map) => ClaimResult(
      id: map['id'].toString(),
      originalClaim: map['originalClaim'],
      verdict: Verdict.values.firstWhere(
        (v) => v.name == map['verdict'],
        orElse: () => Verdict.needsVerification,
      ),
      kidExplanation: map['kidExplanation'],
      safetyFlag: SafetyFlag.values.firstWhere(
        (s) => s.name == map['safetyFlag'],
        orElse: () => SafetyFlag.safe,
      ),
      safetyReason: map['safetyReason'] ?? '',
      pointsAwarded: map['pointsAwarded'],
      timestamp: DateTime.parse(map['timestamp']),
    )).toList();
  }

  // Gets total points from local SQLite
  Future<int> getTotalPoints(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'points',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return 0;
    return maps.first['totalPoints'] ?? 0;
  }

  // Adds points to SQLite and syncs to Firestore
  Future<void> addPoints(String userId, int points) async {
    // Update local SQLite
    final db = await database;
    final current = await getTotalPoints(userId);
    await db.insert(
      'points',
      {'userId': userId, 'totalPoints': current + points},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Sync total points to Firestore
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(
            {'totalPoints': current + points},
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Firestore points sync failed (offline?): $e');
    }
  }

  // Deletes all data from both SQLite and Firestore
  Future<void> deleteAllUserData(String userId) async {
    // Delete from local SQLite
    final db = await database;
    await db.delete('claims', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('points', where: 'userId = ?', whereArgs: [userId]);

    // Delete from Firestore
    try {
      final claims = await _firestore
          .collection('users')
          .doc(userId)
          .collection('claims')
          .get();

      final batch = _firestore.batch();
      for (final doc in claims.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore.collection('users').doc(userId));
      await batch.commit();
    } catch (e) {
      print('Firestore deletion failed: $e');
    }
  }
}