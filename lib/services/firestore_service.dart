import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// إنشاء / تحديث مستخدم
  static Future<void> upsertUser({
    required String phone,
    required String password,
  }) async {
    await _db.collection('users').doc(phone).set({
      'phone': phone,
      'password': password,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// جلب بيانات مستخدم
  static Future<Map<String, dynamic>?> getUser(String phone) async {
    final doc = await _db.collection('users').doc(phone).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// إضافة إشعار عام
  static Future<void> addBroadcast(String message) async {
    await _db.collection('broadcasts').add({
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ستريم المستخدمين (للشاشة الإدارية)
  static Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return _db
        .collection('users')
        .orderBy('phone', descending: false)
        .snapshots();
  }

  /// ستريم الحجوزات
  static Stream<QuerySnapshot<Map<String, dynamic>>> bookingsStream() {
    return _db
        .collection('appointments')
        .orderBy('date', descending: false)
        .snapshots();
  }

  /// ستريم المتابعات
  static Stream<QuerySnapshot<Map<String, dynamic>>> followupsStream() {
    return _db
        .collection('followups')
        .orderBy('date', descending: false)
        .snapshots();
  }

  /// حذف مستخدم
  static Future<void> deleteUser(String phone) async {
    await _db.collection('users').doc(phone).delete();
  }
}
