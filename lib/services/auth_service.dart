import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

enum AdminRole { admin, secretary }

class AuthService {
  // كلمات السر الافتراضية
  static const String _defaultAdminPass = 'DrMo@111994';
  static const String _defaultSecretaryPass = 'Sec@2025';

  // مفاتيح التخزين المحلي (لو حابب تغير من جوه التطبيق)
  static const _adminPassKey = 'admin_master_pass';
  static const _secretaryPassKey = 'secretary_pass';

  /// تسجيل دخول الأدمن / السكرتيرة
  static Future<AdminRole?> loginAdmin(String password) async {
    final prefs = await SharedPreferences.getInstance();

    final admin = prefs.getString(_adminPassKey) ?? _defaultAdminPass;
    final sec = prefs.getString(_secretaryPassKey) ?? _defaultSecretaryPass;

    if (password == admin) return AdminRole.admin;
    if (password == sec) return AdminRole.secretary;
    return null;
  }

  /// تغيير باسورد الأدمن (لو حبيت تستخدمها لاحقًا)
  static Future<void> setAdminPassword(String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminPassKey, pass);
  }

  /// تغيير باسورد السكرتيرة (دي اللي هنستخدمها من شاشة الأدمن)
  static Future<void> setSecretaryPassword(String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_secretaryPassKey, pass);
  }

  /// إعداد / تعديل باسورد المريض حسب رقم التليفون
  static Future<void> setUserPassword(String phone, String pass) async {
    await FirestoreService.upsertUser(phone: phone, password: pass);
  }

  /// تسجيل دخول المريض
  static Future<bool> loginUser(String phone, String pass) async {
    final u = await FirestoreService.getUser(phone);
    if (u == null) return false;
    return (u['password'] ?? '') == pass;
  }
}
