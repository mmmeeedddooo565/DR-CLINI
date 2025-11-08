import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمون'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.usersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون بعد'));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final phone = data['phone']?.toString() ?? '';
              final name = data['name']?.toString() ?? 'بدون اسم';
              final pass = data['password']?.toString() ?? '';

              return ListTile(
                title: Text(name),
                subtitle: Text('موبايل: $phone\nباسورد: $pass'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirestoreService.deleteUser(phone);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف المستخدم'),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
