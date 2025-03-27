// C:\Users\ilies\git\appEnnour\lib\pages\admin\admin_quizzes_page.dart

import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../../widgets/admin/loading_indicator.dart';
import '../../widgets/index.dart';
import 'admin_quiz_form_page.dart';

class AdminQuizzesPage extends StatefulWidget {
  static const String routeName = '/admin/quizzes';

  const AdminQuizzesPage({Key? key}) : super(key: key);

  @override
  State<AdminQuizzesPage> createState() => _AdminQuizzesPageState();
}

class _AdminQuizzesPageState extends State<AdminQuizzesPage> {
  final AdminCourseService _courseService = AdminCourseService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer tous les cours
      final courses = await _courseService.getAllCourses();

      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: $e';
        _isLoading = false;
      });
      print('Erreur de chargement des quiz: $e');
    }
  }

  Future<void> _navigateToQuizForm(String courseId, Quiz quiz) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminQuizFormPage(
          courseId: courseId,
          quiz: quiz,
        ),
      ),
    );

    // Recharger les données si le quiz a été mis à jour
    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _createOrEditQuiz(Course course) async {
    // Si le quiz existe déjà, on l'édite, sinon on en crée un nouveau
    if (course.quiz.id.isNotEmpty) {
      _navigateToQuizForm(course.id, course.quiz);
    } else {
      // Créer un nouveau quiz vide
      final newQuiz = Quiz(
        id: 'quiz-${DateTime.now().millisecondsSinceEpoch}',
        title: '${course.title} - Quiz',
        description: 'Quiz pour le cours ${course.title}',
        questions: [],
      );

      // Mettre à jour le cours avec le nouveau quiz
      try {
        final updatedCourse = course.copyWith(quiz: newQuiz);
        await _courseService.updateCourse(updatedCourse);

        if (mounted) {
          _navigateToQuizForm(course.id, newQuiz);
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Erreur lors de la création du quiz: $e',
            backgroundColor: Colors.red,
          );
        }
      }
    }
  }

  Future<void> _deleteQuiz(Course course) async {
    // Vérifier que le quiz existe
    if (course.quiz.id.isEmpty) {
      return; // Pas de quiz à supprimer
    }

    // Demander confirmation
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Supprimer le quiz',
      message: 'Êtes-vous sûr de vouloir supprimer le quiz "${course.quiz.title}" ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (!confirmed) return;

    // Créer un quiz vide pour remplacer l'existant
    final emptyQuiz = Quiz(
      id: '',
      title: '',
      description: '',
      questions: [],
    );

    // Supprimer le quiz en mettant à jour le cours
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedCourse = course.copyWith(quiz: emptyQuiz);
      await _courseService.updateCourse(updatedCourse);

      // Mettre à jour l'état local
      setState(() {
        final index = _courses.indexWhere((c) => c.id == course.id);
        if (index >= 0) {
          _courses[index] = updatedCourse;
        }
        _isLoading = false;
      });

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Le quiz a été supprimé avec succès',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la suppression du quiz: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  bool _courseHasQuiz(Course course) {
    return course.quiz.id.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Gestion des Quiz',
        showBackButton: true,
      ),
      drawer: const AdminDrawer(currentRoute: AdminQuizzesPage.routeName),
      body: _isLoading
          ? const LoadingIndicator()
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
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _courses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun cours disponible.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vous devez d\'abord créer des cours avant de pouvoir ajouter des quiz.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Description de la page
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Gestion des quiz',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cette page vous permet de gérer les quiz pour chaque cours. Vous pouvez créer, modifier et supprimer des quiz.',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chaque cours peut avoir un quiz associé. Cliquez sur les boutons d\'action pour gérer les quiz.',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Liste des cours avec leurs quiz
            ...List.generate(
              _courses.length,
                  (index) {
                final course = _courses[index];
                final hasQuiz = _courseHasQuiz(course);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête du cours
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppUtils.translateLevel(course.level),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                hasQuiz ? Icons.edit : Icons.add,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: () => _createOrEditQuiz(course),
                              tooltip: hasQuiz ? 'Modifier le quiz' : 'Créer un quiz',
                            ),
                          ],
                        ),
                      ),

                      // Informations sur le quiz
                      if (hasQuiz)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre et description du quiz
                              Row(
                                children: [
                                  const Icon(Icons.quiz, size: 20, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      course.quiz.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course.quiz.description,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Nombre de questions
                              Row(
                                children: [
                                  Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${course.quiz.questions.length} question${course.quiz.questions.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Boutons d'action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _navigateToQuizForm(course.id, course.quiz),
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    label: const Text('Modifier', style: TextStyle(color: Colors.blue)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _deleteQuiz(course),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Aucun quiz pour ce cours',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _createOrEditQuiz(course),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Créer un quiz'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Ajout du nouveau bouton flottant ici
      floatingActionButton: _courses.isEmpty ? null : FloatingActionButton.extended(
        onPressed: () {
          // Code pour afficher une boîte de dialogue de sélection de cours
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Choisir un cours'),
              content: SizedBox(
                width: double.maxFinite,
                child: _courses.where((course) => !_courseHasQuiz(course)).isEmpty
                    ? const Text('Tous les cours ont déjà un quiz. Veuillez créer un nouveau cours ou supprimer un quiz existant.')
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    if (!_courseHasQuiz(course)) {
                      return ListTile(
                        title: Text(course.title),
                        subtitle: Text(AppUtils.translateLevel(course.level)),
                        onTap: () {
                          Navigator.pop(context);
                          _createOrEditQuiz(course);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          );
        },
        label: const Text('Nouveau quiz'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}