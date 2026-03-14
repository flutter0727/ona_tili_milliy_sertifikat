import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class LiveMonitoringScreen extends StatelessWidget {
  const LiveMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final activeUsers = provider.users.where((u) => u.isInExam).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Jonli Kuzatuv'),
        backgroundColor: const Color(0xFF1F1F1F),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Text('${activeUsers.length} ta faol', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: activeUsers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_heart_outlined, size: 80, color: Colors.white10),
                  SizedBox(height: 16),
                  Text('Hozirda hech kim test topshirmayapti', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeUsers.length,
              itemBuilder: (context, index) {
                final user = activeUsers[index];
                return Card(
                  color: const Color(0xFF1F1F1F),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.green, width: 0.5)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Imtihon: ${user.currentExamTitle ?? "Nomsiz"}', style: const TextStyle(color: Colors.teal, fontSize: 12)),
                        Text('ID: ${user.loginId}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    trailing: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ONLAYN', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
