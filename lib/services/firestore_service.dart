import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections جاهزة لإعادة استخدام الكود القديم
  static CollectionReference<Map<String, dynamic>> get usersCol =>
      _db.collection('users');
  static CollectionReference<Map<String, dynamic>> get appointmentsCol =>
      _db.collection('appointments');
  static CollectionReference<Map<String, dynamic>> get followupsCol =>
      _db.collection('followups');
  static CollectionReference<Map<String, dynamic>> get broadcastsCol =>
      _db.collection('broadcasts');
  static CollectionReference<Map<String, dynamic>> get settingsCol =>
      _db.collection('settings');

  /// إنشاء / تحديث مستخدم
  /// الكود القديم أحيانًا كان يبعت name، فخليناه اختياري.
  static Future<void> upsertUser({
  required String phone,
  String? password,
  String? name,
  int? age,
}) async {
  final data = <String, dynamic>{
    'phone': phone,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  if (password != null && password.isNotEmpty) {
    data['password'] = password;
  }
  if (name != null && name.isNotEmpty) {
    data['name'] = name;
  }
  if (age != null) {
    data['age'] = age;
  }

  await usersCol.doc(phone).set(data, SetOptions(merge: true));
}


  /// جلب بيانات مستخدم (لتسجيل الدخول)
  static Future<Map<String, dynamic>?> getUser(String phone) async {
    final doc = await usersCol.doc(phone).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// إضافة إشعار عام
  static Future<void> addBroadcast(String message) async {
    await broadcastsCol.add({
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// جلب الإشعارات (للشاشة notifications_screen)
  static Future<List<Map<String, dynamic>>> getBroadcasts() async {
    final snap = await broadcastsCol
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// ستريم المستخدمين (AdminUsersScreen)
  static Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return usersCol.orderBy('phone').snapshots();
  }

  /// ستريم الحجوزات (AdminBookingsScreen)
  static Stream<QuerySnapshot<Map<String, dynamic>>> bookingsStream() {
    return appointmentsCol.orderBy('date').snapshots();
  }

  /// ستريم المتابعات (AdminFollowupsScreen)
  static Stream<QuerySnapshot<Map<String, dynamic>>> followupsStream() {
    return followupsCol.orderBy('date').snapshots();
  }

  /// حذف مستخدم
  static Future<void> deleteUser(String phone) async {
    await usersCol.doc(phone).delete();
  }
}
