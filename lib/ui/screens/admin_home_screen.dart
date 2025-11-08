import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/appointment_service.dart';
import 'admin_users_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_followups_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final AdminRole? role;
  const AdminHomeScreen({super.key, this.role});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late AdminRole _role;
  final _patientPhone = TextEditingController();
  final _manualPass = TextEditingController();
  final _broadcast = TextEditingController();

  bool get isSecretary => _role == AdminRole.secretary;
  bool get isAdmin => _role == AdminRole.admin;

  @override
  void initState() {
    super.initState();
    _role = widget.role ?? AdminRole.admin;
  }

  Future<void> _setPassword() async {
    final isAr = context.read<LanguageService>().isArabic;
    final phone = _patientPhone.text.trim();
    final pass = _manualPass.text.trim();
    if (phone.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'أدخل رقم الموبايل وكلمة المرور'
                : 'Enter phone & password',
          ),
        ),
      );
      return;
    }
    await AuthService.setUserPassword(phone, pass);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'تم حفظ كلمة المرور للمستخدم'
              : 'Password saved for user',
        ),
      ),
    );
  }

  Future<void> _postBroadcast() async {
    final msg = _broadcast.text.trim();
    if (msg.isEmpty) return;
    await FirestoreService.addBroadcast(msg);
    _broadcast.clear();
    final isAr = context.read<LanguageService>().isArabic;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr ? 'تم إرسال الإشعار' : 'Broadcast sent',
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _todaySummary() async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    return await AppointmentService.buildSlotsForDay(day);
  }

  Future<void> _changeSecretaryPassword() async {
    if (!isAdmin) return;
    final isAr = context.read<LanguageService>().isArabic;
    final controller = TextEditingController();

    final newPass = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection:
              isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: AlertDialog(
            title: Text(
              isAr
                  ? 'تغيير كلمة مرور السكرتيرة'
                  : 'Change secretary password',
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: isAr
                    ? 'أدخل كلمة المرور الجديدة'
                    : 'Enter new password',
              ),
              obscureText: true,
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(null),
                child: Text(isAr ? 'إلغاء' : 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext)
                    .pop(controller.text.trim()),
                child: Text(isAr ? 'حفظ' : 'Save'),
              ),
            ],
          ),
        );
      },
    );

    if (newPass != null && newPass.isNotEmpty) {
      await AuthService.setSecretaryPassword(newPass);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'تم تغيير كلمة مرور السكرتيرة بنجاح ✅'
                : 'Secretary password updated ✅',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;
    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isSecretary
                ? (isAr ? 'لوحة السكرتيرة' : 'Secretary Dashboard')
                : (isAr ? 'لوحة الأدمن' : 'Admin Dashboard'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: isAr ? 'الحجوزات' : 'Bookings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminBookingsScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.event_note),
              tooltip: isAr ? 'متابعات' : 'Follow-ups',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminFollowupsScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: isAr ? 'المستخدمون' : 'Users',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                );
              },
            ),
            if (!isSecretary)
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: isAr ? 'إعدادات' : 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminSettingsScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // موجز حجوزات اليوم
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _todaySummary(),
                builder: (context, snap) {
                  if (snap.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    );
                  }
                  if (!snap.hasData || snap.hasError) {
                    return const SizedBox.shrink();
                  }
                  final slots = snap.data!;
                  final total = slots.fold<int>(
                    0,
                    (p, e) => p + (e['used'] as int),
                  );
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr
                                ? 'موجز حجوزات اليوم'
                                : "Today's bookings summary",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (isAr
                                    ? 'إجمالي الحجوزات: '
                                    : 'Total bookings: ') +
                                total.toString(),
                          ),
                          const SizedBox(height: 4),
                          ...slots.map(
                            (s) => Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(s['time'] as String),
                                Text(
                                  isAr
                                      ? 'محجوز: ${s['used']}/${s['capacity']}'
                                      : 'Booked: ${s['used']}/${s['capacity']}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // زر تغيير كلمة مرور السكرتيرة - للأدمن فقط
              if (isAdmin) ...[
                FilledButton.icon(
                  onPressed: _changeSecretaryPassword,
                  icon: const Icon(Icons.lock_reset),
                  label: Text(
                    isAr
                        ? 'تغيير كلمة مرور السكرتيرة'
                        : 'Change secretary password',
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // تعيين كلمة مرور لمستخدم
              Text(
                isAr
                    ? 'تعيين كلمة مرور لمستخدم'
                    : 'Set user password',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _patientPhone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText:
                      isAr ? 'رقم موبايل المستخدم' : 'User phone',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _manualPass,
                decoration: InputDecoration(
                  labelText: isAr ? 'كلمة المرور' : 'Password',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _setPassword,
                child: Text(
                  isAr
                      ? 'حفظ كلمة المرور'
                      : 'Save password',
                ),
              ),

              const SizedBox(height: 24),

              // إشعار عام
              Text(
                isAr
                    ? 'إشعار عام لكل المستخدمين'
                    : 'Broadcast message',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _broadcast,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isAr
                      ? 'اكتب رسالة قصيرة تظهر في الإشعارات داخل التطبيق'
                      : 'Write a short in-app notification',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _postBroadcast,
                icon: const Icon(Icons.campaign),
                label: Text(isAr ? 'إرسال' : 'Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
