import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.loginId,
    required super.phoneNumber,
    required super.results,
    super.isInExam,
    super.currentExamTitle,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? 'unknown_user',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      loginId: json['loginId']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      results: (json['results'] as List? ?? [])
          .map((item) => UserResultModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'loginId': loginId,
      'phoneNumber': phoneNumber,
      'results': results.map((r) => (r as UserResultModel).toJson()).toList(),
    };
  }
}

class UserResultModel extends UserResult {
  UserResultModel({
    required super.examId,
    required super.examTitle,
    required super.testScore,
    required super.essayContent,
    super.essayScore,
    required super.date,
    super.isPublished,
  });

  factory UserResultModel.fromJson(Map<String, dynamic> json) {
    return UserResultModel(
      examId: json['examId']?.toString() ?? '',
      examTitle: json['examTitle']?.toString() ?? 'Nomsiz imtihon',
      testScore: double.tryParse(json['testScore']?.toString() ?? '0.0') ?? 0.0,
      essayContent: json['essayContent']?.toString() ?? '',
      essayScore: json['essayScore'] != null ? double.tryParse(json['essayScore'].toString()) : null,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'examTitle': examTitle,
      'testScore': testScore,
      'essayContent': essayContent,
      'essayScore': essayScore,
      'date': date.toIso8601String(),
      'isPublished': isPublished,
    };
  }
}
