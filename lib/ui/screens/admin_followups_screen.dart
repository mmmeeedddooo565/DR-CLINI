import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AdminFollowupsScreen extends StatelessWidget {
  const AdminFollowupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواعيد المتابعات'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.followupsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('لا توجد متابعات مسجلة'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final date = data['date']?.toString() ?? '';
              final phone = data['phone']?.toString() ?? '';
              final name = data['name']?.toString() ?? '';
              final note = data['note']?.toString() ?? '';

              return ListTile(
                title: Text(
                  '$date - ${name.isNotEmpty ? name : phone}',
                ),
                subtitle: note.isNotEmpty ? Text(note) : null,
              );
            },
          );
        },
      ),
    );
  }
}
