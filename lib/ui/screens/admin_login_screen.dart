import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import 'admin_home_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final role = await AuthService.loginAdmin(_pass.text.trim());

    setState(() => _loading = false);

    if (!mounted) return;

    final isAr = context.read<LanguageService>().isArabic;

    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'كلمة المرور غير صحيحة'
                : 'Invalid password',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdminHomeScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageService>().isArabic;

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'دخول الإدارة' : 'Admin / Secretary Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isAr ? 'كلمة المرور' : 'Password',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return isAr
                          ? 'من فضلك أدخل كلمة المرور'
                          : 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(isAr ? 'دخول' : 'Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
