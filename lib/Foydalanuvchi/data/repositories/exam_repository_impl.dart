import '../../domain/entities/question.dart';
import '../../domain/repositories/exam_repository.dart';
import '../../../core/data/questions_data.dart';

class ExamRepositoryImpl implements ExamRepository {
  @override
  Future<List<Question>> getQuestions() async {
    // Endi savollar QuestionsData dan olinadi
    await Future.delayed(const Duration(seconds: 1));
    return QuestionsData.getStaticQuestions();
  }

  @override
  Future<bool> submitResult(double score, String userId) async {
    return true;
  }
}
