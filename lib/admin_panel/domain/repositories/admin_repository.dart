import '../../../foydalanuvchi/domain/entities/question.dart';

abstract class AdminRepository {
  Future<void> addQuestion(Question question);
  Future<List<Question>> getAllQuestions();
  Future<void> deleteQuestion(String id);
}
