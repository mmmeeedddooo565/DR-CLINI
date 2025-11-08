import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

enum AdminRole { admin, secretary }

class AuthService {
  // كلمات المرور الافتراضية
  static const String _defaultAdminPass = 'DrMo@111994';
  static const String _defaultSecretaryPass = 'Sec@2025';

  // مفاتيح التخزين المحلي
  static const String _adminPassKey = 'admin_master_pass';
  static const String _secretaryPassKey = 'secretary_pass';

  /// تسجيل دخول الأدمن / السكرتيرة
  static Future<AdminRole?> loginAdmin(String password) async {
    final prefs = await SharedPreferences.getInstance();

    final adminPass = prefs.getString(_adminPassKey) ?? _defaultAdminPass;
    final secPass =
        prefs.getString(_secretaryPassKey) ?? _defaultSecretaryPass;

    if (password == adminPass) return AdminRole.admin;
    if (password == secPass) return AdminRole.secretary;
    return null;
  }

  /// تغيير كلمة مرور الأدمن (لو حبيت تستخدمها بعدين من شاشة إعدادات)
  static Future<void> setAdminPassword(String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminPassKey, pass);
  }

  /// تغيير كلمة مرور السكرتيرة (يُستدعى من لوحة الأدمن)
  static Future<void> setSecretaryPassword(String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_secretaryPassKey, pass);
  }

  /// تعيين / تعديل كلمة مرور مستخدم (مريض) حسب رقم الموبايل
  static Future<void> setUserPassword(String phone, String pass) async {
    await FirestoreService.upsertUser(
      phone: phone,
      password: pass,
    );
  }

  /// تسجيل دخول المريض
  static Future<bool> loginUser(String phone, String pass) async {
    final user = await FirestoreService.getUser(phone);
    if (user == null) return false;
    return (user['password'] ?? '') == pass;
  }
}
