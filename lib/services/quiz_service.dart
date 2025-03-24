import 'dart:async';
import '../models/index.dart';
import 'mock_data_service.dart';
import 'auth_service.dart';

// Service pour gérer les quizz et les scores
class QuizService {
  final MockDataService _mockDataService = MockDataService();
  final AuthService _authService = AuthService();

  // Singleton pattern
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  // Récupère un quiz par son ID
  Future<Quiz?> getQuizById(String quizId) async {
    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 400));

    // Rechercher dans tous les cours pour trouver celui avec le quiz correspondant
    final courses = _mockDataService.courses;
    for (final course in courses) {
      if (course.quiz.id == quizId) {
        return course.quiz;
      }
    }

    return null;
  }

  // Soumet les réponses d'un quiz et calcule le score
  Future<int> submitQuiz(String quizId, Map<String, int> answers) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Récupère le quiz
    final quiz = await getQuizById(quizId);
    if (quiz == null) {
      return 0; // Quiz non trouvé
    }

    // Calcule le score
    int correctAnswers = 0;

    for (final question in quiz.questions) {
      if (answers.containsKey(question.id) &&
          question.isCorrect(answers[question.id]!)) {
        correctAnswers++;
      }
    }

    // Calculer le pourcentage
    final score = (correctAnswers / quiz.questions.length * 100).round();

    // Enregistrer le score pour l'utilisateur actuel si connecté
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _mockDataService.updateQuizScore(currentUser.id, quizId, score);
    }

    return score;
  }

  // Vérifie si un quiz a déjà été réalisé par l'utilisateur
  Future<bool> hasCompletedQuiz(String quizId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return false;
    }

    return currentUser.quizScores.containsKey(quizId);
  }

  // Récupère le score d'un quiz spécifique pour l'utilisateur actuel
  Future<int?> getUserQuizScore(String quizId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return null;
    }

    return currentUser.quizScores[quizId];
  }

  // Récupère tous les scores de l'utilisateur actuel
  Future<Map<String, int>> getUserQuizScores() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return {};
    }

    return currentUser.quizScores;
  }

// TODO: Implémenter les appels API réels lorsque le backend sera prêt
// Future<bool> submitQuizToApi(String quizId, Map<String, int> answers) async {
//   // Implémentation future avec http package
//   return false;
// }
}