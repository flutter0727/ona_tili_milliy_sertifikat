class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String category; // Yangi maydon

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    this.category = 'Umumiy',
  });
}
