import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'create_exam_screen.dart';

class ExamSettingsScreen extends StatelessWidget {
  const ExamSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Imtihonlarni boshqarish'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.exams.length,
              itemBuilder: (context, index) {
                final exam = provider.exams[index];
                return Card(
                  color: const Color(0xFF1F1F1F),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.event_available, color: Colors.teal),
                    title: Text(exam.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Boshlanishi: ${exam.startTime.day}.${exam.startTime.month} ${exam.startTime.hour}:${exam.startTime.minute}\nDavomiyligi: ${exam.durationMinutes} daqiqa',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: Text('${exam.questionIds.length} ta savol', style: const TextStyle(color: Colors.teal, fontSize: 10)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateExamScreen())),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('YANGI IMTIHON YARATISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ),
          )
        ],
      ),
    );
  }
}
