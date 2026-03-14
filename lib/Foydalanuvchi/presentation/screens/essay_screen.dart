import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../../../admin_panel/presentation/providers/admin_provider.dart';
import 'login_screen.dart';

class EssayScreen extends StatefulWidget {
  const EssayScreen({super.key});

  @override
  State<EssayScreen> createState() => _EssayScreenState();
}

class _EssayScreenState extends State<EssayScreen> {
  final _controller = TextEditingController();

  void _submitEssay() {
    final examProvider = context.read<ExamProvider>();
    final adminProvider = context.read<AdminProvider>();

    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse yozilmagan!')),
      );
      return;
    }

    if (examProvider.currentUser == null || examProvider.activeExam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xatolik: Foydalanuvchi yoki imtihon topilmadi!')),
      );
      return;
    }

    // Natijani saqlash
    adminProvider.submitUserResult(
      userId: examProvider.currentUser!.id,
      examId: examProvider.activeExam!.id,
      examTitle: examProvider.activeExam!.title,
      testScore: examProvider.testScore,
      essayContent: _controller.text,
    );

    // Monitoringni to'xtatish
    adminProvider.updateUserStatus(examProvider.currentUser!.id, isInExam: false);

    // Xavfsizlik uchun providerni tozalash
    examProvider.clearExam();

    // Faqat ID teriladigan page (UserLoginScreen) ga o'tish va orqaga qaytishni bloklash
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const UserLoginScreen()),
      (route) => false,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imtihon yakunlandi. Natijalar ustoz tomonidan tekshiriladi.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = context.read<ExamProvider>();
    final task = examProvider.activeExam?.essayTask;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imtihon paytida chiqib keta olmaysiz!')),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('2-qism: Esse yozish'),
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ESSE MAVZUSI:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                    const SizedBox(height: 10),
                    Text(
                      task?.topic ?? 'Ona tili — millatning ruhi va ma\'naviy xazinasi.',
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Matnni shu yerga yozing...',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitEssay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('IMTIHONNI TUGATISH', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
