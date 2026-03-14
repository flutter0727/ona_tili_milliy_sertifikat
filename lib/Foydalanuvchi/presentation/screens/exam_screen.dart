import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../../../admin_panel/presentation/providers/admin_provider.dart';
import 'essay_screen.dart';
import 'dart:async';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late Timer _timer;
  int _timeLeft = 5400; // Default 90 minutes

  @override
  void initState() {
    super.initState();
    final examProvider = context.read<ExamProvider>();
    final adminProvider = context.read<AdminProvider>();

    if (examProvider.activeExam != null) {
      _timeLeft = examProvider.activeExam!.durationMinutes * 60;
      
      if (examProvider.currentUser != null) {
        adminProvider.updateUserStatus(
          examProvider.currentUser!.id, 
          isInExam: true, 
          examTitle: examProvider.activeExam!.title
        );
      }
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _timer.cancel();
        _finishTestPart(isAuto: true);
      }
    });
  }

  void _finishTestPart({bool isAuto = false}) {
    if (_timer.isActive) _timer.cancel();
    
    final examProvider = context.read<ExamProvider>();
    examProvider.calculateTestScore();

    if (!mounted) return;

    // Ballni ko'rsatmasdan to'g'ridan-to'g'ri Esse qismiga o'tamiz
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EssayScreen()),
    );
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Savollar yuklanmadi')));
    }

    final currentQuestion = provider.questions[provider.currentIndex];

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
          backgroundColor: const Color(0xFF1A237E),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ona tili (Test)', style: TextStyle(color: Colors.white, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 18),
                    const SizedBox(width: 5),
                    Text(_formatTime(_timeLeft), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 70,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: provider.questions.length,
                itemBuilder: (context, index) {
                  bool isCurrent = provider.currentIndex == index;
                  bool isAnswered = provider.answers.containsKey(index);
                  return GestureDetector(
                    onTap: () => provider.goToQuestion(index),
                    child: Container(
                      width: 45,
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.blue[800] : (isAnswered ? Colors.green[500] : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent ? Border.all(color: Colors.orange, width: 2) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text('${index + 1}', style: TextStyle(color: (isCurrent || isAnswered) ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.blue[800]),
                          const SizedBox(width: 10),
                          Text('SAVOL № ${provider.currentIndex + 1}', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentQuestion.text, style: const TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 30),
                            ...List.generate(currentQuestion.options.length, (index) {
                              bool isSelected = provider.answers[provider.currentIndex] == index;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => provider.selectAnswer(provider.currentIndex, index),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue[50] : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isSelected ? Colors.blue[800]! : Colors.grey[300]!, width: isSelected ? 2 : 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30, height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle, 
                                            color: isSelected ? Colors.blue[800] : Colors.grey[100], 
                                            border: Border.all(color: isSelected ? Colors.blue[800]! : Colors.grey[400]!)
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(String.fromCharCode(65 + index), style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(child: Text(currentQuestion.options[index], style: TextStyle(fontSize: 16, color: isSelected ? Colors.blue[800] : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, 
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: provider.currentIndex > 0 ? provider.previousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('OLDINGISI'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), 
                      side: BorderSide(color: provider.currentIndex > 0 ? const Color(0xFF1A237E) : Colors.grey)
                    ),
                  ),
                  if (provider.currentIndex == provider.questions.length - 1)
                    ElevatedButton(
                      onPressed: () => _finishTestPart(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700], 
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                      ),
                      child: const Text('ESSE BOSQICHIGA O\'TISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: provider.nextQuestion,
                      icon: const Text('KEYINGISI'),
                      label: const Icon(Icons.arrow_forward),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E), 
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), 
                        foregroundColor: Colors.white
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
