class QuestionModel {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  QuestionModel({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
    );
  }
}
