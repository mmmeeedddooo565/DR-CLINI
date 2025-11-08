import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحجوزات'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.bookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('لا توجد حجوزات حالياً'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final date = data['date']?.toString() ?? '';
              final time = data['time']?.toString() ?? '';
              final phone = data['phone']?.toString() ?? '';
              final name = data['name']?.toString() ?? '';
              final type = data['type']?.toString() ?? '';

              return ListTile(
                title: Text('$date - $time'),
                subtitle: Text(
                  'مريض: ${name.isNotEmpty ? name : phone}\nالنوع: $type',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
