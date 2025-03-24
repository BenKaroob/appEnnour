// Modèle Quiz qui représente un questionnaire associé à un cours
class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  // Crée une copie de Quiz avec des modifications spécifiques
  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    List<QuizQuestion>? questions,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
    );
  }

  // Création d'un Quiz à partir d'un map (JSON)
  factory Quiz.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return Quiz(
        id: '',
        title: '',
        description: '',
        questions: [],
      );
    }

    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List?)
          ?.map((questionJson) => QuizQuestion.fromJson(questionJson))
          .toList() ??
          [],
    );
  }

  // Conversion du Quiz en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }

  // Calcule le score maximum possible pour ce quiz
  int get maxScore => questions.length * 100;
}

// Modèle QuizQuestion qui représente une question dans un quiz
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final QuestionType type;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.type = QuestionType.multipleChoice,
  });

  // Crée une copie de QuizQuestion avec des modifications spécifiques
  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctOptionIndex,
    QuestionType? type,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      type: type ?? this.type,
    );
  }

  // Création d'un QuizQuestion à partir d'un map (JSON)
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
      type: _parseQuestionType(json['type']),
    );
  }

  // Conversion du QuizQuestion en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'type': type.toString().split('.').last,
    };
  }

  // Vérifie si la réponse donnée est correcte
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctOptionIndex;
  }

  // Conversion de chaîne en QuestionType
  static QuestionType _parseQuestionType(String? typeStr) {
    if (typeStr == 'trueFalse') {
      return QuestionType.trueFalse;
    }
    return QuestionType.multipleChoice;
  }
}

// Énumération des types de questions possibles
enum QuestionType {
  multipleChoice,
  trueFalse,
}