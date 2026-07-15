class QuizQuestion {
  final String id;
  final String difficulty; // Easy, Medium, Hard
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizAttempt {
  final QuizQuestion question;
  final int? selectedIndex;
  const QuizAttempt({required this.question, required this.selectedIndex});
  bool get isCorrect => selectedIndex == question.correctIndex;
  bool get isAnswered => selectedIndex != null;
}
