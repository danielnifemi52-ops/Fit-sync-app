import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import '../../features/auth/services/auth_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(ref),
);

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref _ref;

  FirestoreService(this._ref);

  String? get _userId => _ref.read(authServiceProvider).currentUser?.uid;

  Future<void> saveUserData(UserData userData) async {
    final uid = _userId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(userData.toJson(), SetOptions(merge: true));
  }

  Future<UserData?> getUserData() async {
    final uid = _userId;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserData.fromJson(doc.data()!);
    }
    return null;
  }

  // Future method to sync daily logs (meals, weight history)
  Future<void> saveDailyLog(Map<String, dynamic> logData, DateTime date) async {
    final uid = _userId;
    if (uid == null) return;

    // Format date as YYYY-MM-DD for document ID
    final dateStr = date.toIso8601String().split('T')[0];

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_logs')
        .doc(dateStr)
        .set(logData, SetOptions(merge: true));
  }
}
