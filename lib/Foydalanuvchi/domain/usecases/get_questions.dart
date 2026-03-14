import '../entities/question.dart';
import '../repositories/exam_repository.dart';

class GetQuestions {
  final ExamRepository repository;

  GetQuestions(this.repository);

  Future<List<Question>> call() async {
    return await repository.getQuestions();
  }
}
