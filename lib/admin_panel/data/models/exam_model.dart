import '../../domain/entities/exam_entity.dart';

class ExamModel extends ExamEntity {
  ExamModel({
    required super.id,
    required super.title,
    required super.startTime,
    required super.durationMinutes,
    required super.questionIds,
    required super.userIds,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id']?.toString() ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Nomsiz Imtihon',
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? '') ?? DateTime.now(),
      durationMinutes: int.tryParse(json['durationMinutes']?.toString() ?? '90') ?? 90,
      questionIds: List<String>.from(json['questionIds'] ?? []),
      userIds: List<String>.from(json['userIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'questionIds': questionIds,
      'userIds': userIds,
    };
  }
}
