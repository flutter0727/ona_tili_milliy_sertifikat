class UserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String loginId;
  final String phoneNumber;
  final List<UserResult> results;
  bool isInExam;
  String? currentExamTitle;

  UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.loginId,
    required this.phoneNumber,
    this.results = const [],
    this.isInExam = false,
    this.currentExamTitle,
  });
}

class UserResult {
  final String examId;
  final String examTitle;
  final double testScore; // Testdan olingan ball
  final String essayContent; // Yozilgan esse matni
  double? essayScore; // Ustoz qo'yadigan ball (null bo'lsa hali tekshirilmagan)
  final DateTime date;
  bool isPublished; // Natija o'quvchiga ko'rsatilsinmi?

  UserResult({
    required this.examId,
    required this.examTitle,
    required this.testScore,
    required this.essayContent,
    this.essayScore,
    required this.date,
    this.isPublished = false,
  });

  double get totalScore => testScore + (essayScore ?? 0);
}
