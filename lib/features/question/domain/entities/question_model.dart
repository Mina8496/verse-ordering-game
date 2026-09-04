class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.quiz,
    required this.optionsCount,
    this.options = const {},
  });

  final String id;
  final String quiz;
  final int optionsCount;
  final Map<String, bool> options;
}
