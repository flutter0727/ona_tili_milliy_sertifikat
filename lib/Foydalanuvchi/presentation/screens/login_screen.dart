import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../admin_panel/presentation/providers/admin_provider.dart';
import '../providers/exam_provider.dart';
import 'exam_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _loginIdController = TextEditingController();

  void _attemptLogin() {
    final adminProvider = context.read<AdminProvider>();
    final examProvider = context.read<ExamProvider>();
    
    final loginId = _loginIdController.text;
    
    // 1. Userni bazadan topish
    final user = adminProvider.loginUser(loginId);

    if (user != null) {
      try {
        // 2. Ushbu user qaysi imtihonga biriktirilganini topish
        final activeExam = adminProvider.exams.lastWhere(
          (e) => e.userIds.contains(user.id)
        );

        // 3. ExamProviderga userni va imtihonni saqlash
        examProvider.setCurrentUser(user);
        examProvider.loadQuestionsForExam(activeExam);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExamScreen()),
        );
      } catch (e) {
        _showError('Siz hali hech qanday imtihonga biriktirilmagansiz!');
      }
    } else {
      _showError('Login ID noto\'g\'ri! Iltimos, qayta urinib ko\'ring.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 100, color: Color(0xFF1A237E)),
              const SizedBox(height: 20),
              const Text(
                'Imtihon Tizimiga Kirish',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 10),
              const Text('Admin taqdim etgan IDni kiriting', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: _loginIdController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(color: Colors.grey.withAlpha(50), letterSpacing: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  onPressed: _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('IMTIHONNI BOSHLASH', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
