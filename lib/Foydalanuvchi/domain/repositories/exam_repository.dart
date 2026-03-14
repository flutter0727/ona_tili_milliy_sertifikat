import '../entities/question.dart';

abstract class ExamRepository {
  Future<List<Question>> getQuestions();
  Future<bool> submitResult(double score, String userId);
}
