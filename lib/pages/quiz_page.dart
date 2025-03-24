import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../utils/index.dart';
import '../widgets/index.dart';

// Page de quiz pour évaluer les connaissances
class QuizPage extends StatefulWidget {
  final String courseId;
  final String quizId;

  const QuizPage({
    Key? key,
    required this.courseId,
    required this.quizId,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final CourseService _courseService = CourseService();
  final QuizService _quizService = QuizService();

  bool _isLoading = true;
  Quiz? _quiz;
  Course? _course;
  String? _errorMessage;

  // État du quiz
  int _currentQuestionIndex = 0;
  Map<String, int> _selectedAnswers = {};
  bool _showResult = false;
  int? _quizScore;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  // Chargement du quiz
  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger le quiz et le cours associé
      final quiz = await _quizService.getQuizById(widget.quizId);
      final course = await _courseService.getCourseById(widget.courseId);

      if (quiz == null) {
        setState(() {
          _errorMessage = 'Quiz non trouvé';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _quiz = quiz;
        _course = course;
        _isLoading = false;
        _currentQuestionIndex = 0;
        _selectedAnswers = {};
        _showResult = false;
        _quizScore = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du quiz';
        _isLoading = false;
      });
      print('Erreur de chargement du quiz: $e');
    }
  }

  // Sélection d'une réponse
  void _selectAnswer(int optionIndex) {
    if (_quiz == null || _showResult) return;

    final currentQuestion = _quiz!.questions[_currentQuestionIndex];

    setState(() {
      _selectedAnswers[currentQuestion.id] = optionIndex;
    });
  }

  // Passer à la question suivante
  void _nextQuestion() {
    if (_quiz == null || _currentQuestionIndex >= _quiz!.questions.length - 1) {
      _submitQuiz();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
    });
  }

  // Revenir à la question précédente
  void _previousQuestion() {
    if (_quiz == null || _currentQuestionIndex <= 0) return;

    setState(() {
      _currentQuestionIndex--;
    });
  }

  // Soumettre le quiz pour évaluation
  Future<void> _submitQuiz() async {
    if (_quiz == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculer le score
      final score = await _quizService.submitQuiz(
        _quiz!.id,
        _selectedAnswers,
      );

      setState(() {
        _showResult = true;
        _quizScore = score;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la soumission du quiz';
        _isLoading = false;
      });
      print('Erreur de soumission du quiz: $e');
    }
  }

  // Recommencer le quiz
  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers = {};
      _showResult = false;
      _quizScore = null;
    });
  }

  // Retourner à la page du cours
  void _goBackToCourse() {
    Navigator.pop(context);
  }

  // Construction de la page de résultat
  Widget _buildResultPage() {
    if (_quiz == null || _quizScore == null) return const SizedBox.shrink();

    // Calculer le nombre de réponses correctes
    int correctAnswers = 0;
    for (final question in _quiz!.questions) {
      if (_selectedAnswers.containsKey(question.id) &&
          question.isCorrect(_selectedAnswers[question.id]!)) {
        correctAnswers++;
      }
    }

    return QuizResultWidget(
      score: _quizScore!,
      totalQuestions: _quiz!.questions.length,
      correctAnswers: correctAnswers,
      onRetryPressed: _restartQuiz,
      onNextPressed: _goBackToCourse,
    );
  }

  // Construction de la page de quiz en cours
  Widget _buildQuizInProgress() {
    if (_quiz == null || _quiz!.questions.isEmpty) {
      return const Center(
        child: Text('Aucune question disponible dans ce quiz'),
      );
    }

    final currentQuestion = _quiz!.questions[_currentQuestionIndex];
    final hasSelectedAnswer = _selectedAnswers.containsKey(currentQuestion.id);

    return Column(
      children: [
        // Question actuelle
        QuizQuestionCard(
          question: currentQuestion,
          questionNumber: _currentQuestionIndex + 1,
          totalQuestions: _quiz!.questions.length,
          onOptionSelected: _selectAnswer,
          selectedOptionIndex: _selectedAnswers[currentQuestion.id],
        ),

        // Boutons de navigation
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bouton précédent
              _currentQuestionIndex > 0
                  ? TextButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
              )
                  : const SizedBox(width: 100),

              // Indicateur de question
              Text(
                '${_currentQuestionIndex + 1}/${_quiz!.questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Bouton suivant/terminer
              ElevatedButton(
                onPressed: hasSelectedAnswer ? _nextQuestion : null,
                child: Text(
                  _currentQuestionIndex < _quiz!.questions.length - 1
                      ? 'Suivant'
                      : 'Terminer',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizTitle = _quiz?.title ?? _course?.title ?? 'Quiz';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: quizTitle,
        showBackButton: !_showResult,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuiz,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _showResult
          ? _buildResultPage()
          : SingleChildScrollView(
        child: _buildQuizInProgress(),
      ),

      // Bouton pour soumettre le quiz
      floatingActionButton: !_isLoading &&
          _errorMessage == null &&
          !_showResult &&
          _quiz != null &&
          _selectedAnswers.length == _quiz!.questions.length
          ? FloatingActionButton.extended(
        onPressed: _submitQuiz,
        label: const Text('Soumettre'),
        icon: const Icon(Icons.check),
        backgroundColor: AppTheme.secondaryColor,
      )
          : null,
    );
  }
}