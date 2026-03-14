import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Foydalanuvchi/data/repositories/exam_repository_impl.dart';
import 'Foydalanuvchi/domain/usecases/get_questions.dart';
import 'Foydalanuvchi/presentation/providers/exam_provider.dart';
import 'Foydalanuvchi/presentation/providers/essay_provider.dart';
import 'Foydalanuvchi/presentation/screens/login_screen.dart';
import 'admin_panel/presentation/providers/admin_provider.dart';
import 'admin_panel/presentation/screens/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ni ishga tushirish
  await Hive.initFlutter();
  
  // Box'larni ochish
  await Hive.openBox('exams_box');
  await Hive.openBox('users_box');
  await Hive.openBox('settings_box');
  await Hive.openBox('session_box'); // Yangi sessiya boxi

  final examRepository = ExamRepositoryImpl();
  final getQuestionsUseCase = GetQuestions(examRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExamProvider(getQuestionsUseCase: getQuestionsUseCase),
        ),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => EssayProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ona tili Milliy Sertifikat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const ChoiceScreen(),
    );
  }
}

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 80, color: Color(0xFF1A237E)),
            const SizedBox(height: 20),
            const Text(
              'Ona tili Milliy Sertifikat\nTizimi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 50),
            _buildChoiceButton(
              context,
              'Imtihon topshirish',
              Icons.assignment_ind,
              const Color(0xFF1A237E),
              const UserLoginScreen(),
            ),
            const SizedBox(height: 20),
            _buildChoiceButton(
              context,
              'Admin Boshqaruvi',
              Icons.admin_panel_settings,
              const Color(0xFF004D40),
              const AdminHomeScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(BuildContext context, String label, IconData icon, Color color, Widget screen) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
