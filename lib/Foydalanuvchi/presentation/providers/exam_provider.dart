import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/question.dart';
import '../../domain/usecases/get_questions.dart';
import '../../../admin_panel/domain/entities/exam_entity.dart';
import '../../../admin_panel/domain/entities/user_entity.dart';
import '../../../admin_panel/data/models/exam_model.dart';
import '../../../admin_panel/data/models/user_model.dart';
import 'dart:math';

class ExamProvider extends ChangeNotifier {
  final GetQuestions getQuestionsUseCase;
  final Box _sessionBox = Hive.box('session_box');

  List<Question> _questions = [];
  List<Question> get questions => _questions;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Map<int, int?> _answers = {};
  Map<int, int?> get answers => _answers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ExamEntity? _activeExam;
  ExamEntity? get activeExam => _activeExam;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  double _testScore = 0.0;
  double get testScore => _testScore;

  ExamProvider({required this.getQuestionsUseCase}) {
    _loadPersistedSession();
  }

  // Restartdan keyin jarayonni qayta tiklash
  void _loadPersistedSession() {
    if (_sessionBox.get('active_user') != null) {
      _currentUser = UserModel.fromJson(Map<String, dynamic>.from(_sessionBox.get('active_user')));
    }
    if (_sessionBox.get('active_exam') != null) {
      _activeExam = ExamModel.fromJson(Map<String, dynamic>.from(_sessionBox.get('active_exam')));
    }
    final savedAnswers = _sessionBox.get('current_answers');
    if (savedAnswers != null) {
      _answers = Map<int, int?>.from(savedAnswers);
    }
    _currentIndex = _sessionBox.get('current_index') ?? 0;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    if (_currentUser != null) {
      await _sessionBox.put('active_user', (_currentUser as UserModel).toJson());
    }
    if (_activeExam != null) {
      await _sessionBox.put('active_exam', (_activeExam as ExamModel).toJson());
    }
    await _sessionBox.put('current_answers', _answers);
    await _sessionBox.put('current_index', _currentIndex);
  }

  void setCurrentUser(UserEntity user) {
    _currentUser = user;
    _saveSession();
    notifyListeners();
  }

  Future<void> loadQuestionsForExam(ExamEntity exam) async {
    _isLoading = true;
    _activeExam = exam;
    notifyListeners();
    
    List<Question> allQuestions = await getQuestionsUseCase();
    _questions = allQuestions.where((q) => exam.questionIds.contains(q.id)).toList();
    
    // Agar sessiya yangi bo'lsa aralashtiramiz
    if (_answers.isEmpty) {
      _questions.shuffle(Random());
    }
    
    await _saveSession();
    _isLoading = false;
    notifyListeners();
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    _answers[questionIndex] = answerIndex;
    _saveSession();
    notifyListeners();
  }

  void calculateTestScore() {
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctOptionIndex) {
        correctCount++;
      }
    }
    _testScore = (correctCount / (_questions.isEmpty ? 1 : _questions.length)) * 100;
    notifyListeners();
  }

  void goToQuestion(int index) {
    _currentIndex = index;
    _saveSession();
    notifyListeners();
  }
  
  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _saveSession();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _saveSession();
      notifyListeners();
    }
  }
  
  Future<void> clearExam() async {
    _questions = [];
    _activeExam = null;
    _currentUser = null;
    _currentIndex = 0;
    _answers = {};
    _testScore = 0.0;
    await _sessionBox.clear();
    notifyListeners();
  }
}
