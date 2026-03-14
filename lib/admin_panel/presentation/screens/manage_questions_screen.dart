import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../Foydalanuvchi/domain/entities/question.dart';

class ManageQuestionsScreen extends StatelessWidget {
  final String category;
  
  const ManageQuestionsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    
    // Savollarni kategoriya bo'yicha filtrlash
    final filteredQuestions = provider.allQuestions.where((q) => q.category == category).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('$category bo\'limi savollari'),
        backgroundColor: const Color(0xFF1F1F1F),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('${filteredQuestions.length} ta', style: const TextStyle(color: Colors.teal))),
          )
        ],
      ),
      body: filteredQuestions.isEmpty 
        ? Center(child: Text('$category bo\'limida hozircha savollar yo\'q', style: const TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredQuestions.length,
            itemBuilder: (context, index) {
              final question = filteredQuestions[index];
              return Card(
                color: const Color(0xFF1F1F1F),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(question.text, style: const TextStyle(color: Colors.white)),
                  children: [
                    // Savol detallari (variantlar va h.k.)
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {}, // Yangi savol qo'shish (kategoriyasi bilan)
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
