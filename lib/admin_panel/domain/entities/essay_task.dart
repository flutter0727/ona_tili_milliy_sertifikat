class EssayTask {
  final String id;
  final String topic;
  final int minWords;
  final List<String> requiredKeywords; // Ball qo'shadigan kalit so'zlar

  EssayTask({
    required this.id,
    required this.topic,
    this.minWords = 150,
    required this.requiredKeywords,
  });
}
