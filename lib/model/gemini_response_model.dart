class MCQQuestion {
  String question;
  List<String> options;
  String correctAnswer;

  MCQQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory MCQQuestion.fromJson(Map<String, dynamic> json) {
    List<String> originalOptions = List<String>.from(json['options']);

    // Ensure correct answer is one of the options
    if (!originalOptions.contains(json['correctAnswer'])) {
      originalOptions[0] = json['correctAnswer'];
    }


    originalOptions.shuffle();

    return MCQQuestion(
      question: json['question'],
      options: originalOptions,
      correctAnswer: json['correctAnswer'],
    );
  }
}
