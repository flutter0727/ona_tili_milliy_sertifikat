import 'package:flutter/material.dart';

class EssayProvider extends ChangeNotifier {
  String _essayContent = '';
  String get essayContent => _essayContent;

  double _currentScore = 0.0;
  double get currentScore => _currentScore;

  void updateContent(String content) {
    _essayContent = content;
    notifyListeners();
  }

  // ESSENI AVTOMATIK BAHOLASH ALGORITMI
  double evaluateEssay(String topic, List<String> keywords, int minWords) {
    if (_essayContent.isEmpty) return 0.0;

    int wordCount = _essayContent.trim().split(RegExp(r'\s+')).length;
    double score = 0.0;

    // 1. Hajm bo'yicha baholash (30 ball)
    if (wordCount >= minWords) {
      score += 30;
    } else {
      score += (wordCount / minWords) * 30;
    }

    // 2. Kalit so'zlar va mazmun (40 ball)
    int foundKeywords = 0;
    for (var keyword in keywords) {
      if (_essayContent.toLowerCase().contains(keyword.toLowerCase())) {
        foundKeywords++;
      }
    }
    score += (foundKeywords / keywords.length) * 40;

    // 3. Imlo va mantiqiy simulyatsiya (30 ball)
    // Haqiqiy AI bo'lmagani uchun simulyatsiya qilamiz
    if (_essayContent.length > 500 && _essayContent.contains('.')) {
      score += 30;
    } else {
      score += 15;
    }

    _currentScore = score;
    notifyListeners();
    return score;
  }
}
