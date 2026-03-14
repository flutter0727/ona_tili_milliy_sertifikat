import 'package:flutter/material.dart';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/user_model.dart';
import '../../../Foydalanuvchi/domain/entities/question.dart';
import '../../../core/data/questions_data.dart';

class AdminProvider extends ChangeNotifier {
  final Box _examsBox = Hive.box('exams_box');
  final Box _usersBox = Hive.box('users_box');

  List<ExamEntity> _exams = [];
  List<ExamEntity> get exams => _exams;

  List<UserEntity> _users = [];
  List<UserEntity> get users => _users;

  final List<Question> _allQuestions = QuestionsData.getStaticQuestions();
  List<Question> get allQuestions => _allQuestions;

  AdminProvider() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      if (_examsBox.isNotEmpty) {
        _exams = _examsBox.values.map((item) {
          return ExamModel.fromJson(Map<String, dynamic>.from(item as Map));
        }).toList();
      }

      if (_usersBox.isNotEmpty) {
        _users = _usersBox.values.map((item) {
          return UserModel.fromJson(Map<String, dynamic>.from(item as Map));
        }).toList();
      }
    } catch (e) {
      debugPrint('Load error: $e');
    }
    notifyListeners();
  }

  Future<void> syncHive() async {
    try {
      // CLEAR QILMASDAN, HAR BIRINI UNIKAL ID BILAN PUT QILAMIZ
      // Bu restart paytida ma'lumotlar o'chib ketishini 100% oldini oladi
      for (var exam in _exams) {
        if (exam is ExamModel) {
          await _examsBox.put(exam.id, exam.toJson());
        }
      }
      for (var user in _users) {
        if (user is UserModel) {
          await _usersBox.put(user.id, user.toJson());
        }
      }
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  void updateUserStatus(String userId, {required bool isInExam, String? examTitle}) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].isInExam = isInExam;
      _users[index].currentExamTitle = examTitle;
      notifyListeners();
    }
  }

  void createExam({
    required String title,
    required DateTime startTime,
    required int duration,
    required List<String> selectedUserIds,
  }) {
    final randomQuestions = List<Question>.from(_allQuestions)..shuffle();
    final selectedIds = randomQuestions.take(45).map((q) => q.id).toList();

    final newExam = ExamModel(
      id: 'exam_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      startTime: startTime,
      durationMinutes: duration,
      questionIds: selectedIds,
      userIds: selectedUserIds,
    );
    
    _exams.add(newExam);
    _examsBox.put(newExam.id, newExam.toJson()); // Darhol Hive'ga yozish
    notifyListeners();
  }

  void addUser(String firstName, String lastName, String phone) {
    final loginId = _generateUniqueLoginId();
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      loginId: loginId,
      phoneNumber: phone,
      results: [],
    );
    _users.add(newUser);
    _usersBox.put(newUser.id, newUser.toJson()); // Darhol Hive'ga yozish
    notifyListeners();
  }

  void submitUserResult({
    required String userId, 
    required String examId, 
    required String examTitle, 
    required double testScore,
    required String essayContent,
  }) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _users[index];
      
      user.results.add(UserResult(
        examId: examId,
        examTitle: examTitle,
        testScore: testScore,
        essayContent: essayContent,
        date: DateTime.now(),
        isPublished: false,
      ));
      
      user.isInExam = false; 
      user.currentExamTitle = null;

      _usersBox.put(user.id, (user as UserModel).toJson()); // Faqat shu userni yangilash
      notifyListeners();
    }
  }

  void gradeAndPublishEssay(String userId, String examId, double score) {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final resultIndex = _users[userIndex].results.indexWhere((r) => r.examId == examId);
      if (resultIndex != -1) {
        _users[userIndex].results[resultIndex].essayScore = score;
        _users[userIndex].results[resultIndex].isPublished = true;
        _usersBox.put(_users[userIndex].id, (_users[userIndex] as UserModel).toJson()); // Hive sinxronlash
        notifyListeners();
      }
    }
  }

  String _generateUniqueLoginId() {
    final random = Random();
    String newId;
    do {
      newId = (random.nextInt(900000) + 100000).toString();
    } while (_users.any((u) => u.loginId == newId));
    return newId;
  }

  UserEntity? loginUser(String loginId) {
    try {
      return _users.firstWhere((u) => u.loginId == loginId);
    } catch (e) {
      return null;
    }
  }
}
