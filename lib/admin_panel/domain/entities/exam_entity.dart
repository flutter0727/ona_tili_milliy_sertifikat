import 'essay_task.dart';

class ExamEntity {
  final String id;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final List<String> questionIds;
  final List<String> userIds;
  final EssayTask? essayTask; // Esse vazifasi qo'shildi

  ExamEntity({
    required this.id,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.questionIds,
    required this.userIds,
    this.essayTask,
  });
}
