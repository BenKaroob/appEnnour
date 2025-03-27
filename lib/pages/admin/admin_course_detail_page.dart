import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import 'admin_course_page.dart';
import 'admin_lesson_form_page.dart';
import 'admin_quiz_form_page.dart';

class AdminCourseDetailPage extends StatefulWidget {
  final String courseId;

  const AdminCourseDetailPage({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<AdminCourseDetailPage> createState() => _AdminCourseDetailPageState();
}

class _AdminCourseDetailPageState extends State<AdminCourseDetailPage> with SingleTickerProviderStateMixin {
  final AdminCourseService _courseService = AdminCourseService();
  final AdminAuthService _authService = AdminAuthService();
  final ActivityLogService _activityLogService = ActivityLogService();

  // Pour la gestion des onglets
  late TabController _tabController;

  // État de la page
  bool _isLoading = true;
  Course? _course;
  Category? _category;
  List<ActivityLog> _courseActivities = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialiser le contrôleur d'onglets
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Charger les données du cours
    _loadCourseDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Gestion du changement d'onglet
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  // Chargement des détails du cours
  Future<void> _loadCourseDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger le cours
      final course = await _courseService.getCourseById(widget.courseId);

      if (course == null) {
        setState(() {
          _errorMessage = 'Cours non trouvé';
          _isLoading = false;
        });
        return;
      }

      // Charger la catégorie
      final category = await _courseService.getCategoryById(course.categoryId);

      // Charger l'historique des activités pour ce cours
      final activities = await _activityLogService.getEntityActivityLogs('course', course.id);

      setState(() {
        _course = course;
        _category = category;
        _courseActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du cours: $e';
        _isLoading = false;
      });
      print('Erreur de chargement du cours: $e');
    }
  }

  // Navigation vers l'édition du cours
  void _navigateToEditCourse() {
    if (_course == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCourseFormPage(
          isEditing: true,
          course: _course,
        ),
      ),
    ).then((_) => _loadCourseDetails());
  }

  // Navigation vers l'ajout d'une nouvelle leçon
  void _navigateToAddLesson() {
    if (_course == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLessonFormPage(
          courseId: _course!.id,
          isEditing: false,
        ),
      ),
    ).then((_) => _loadCourseDetails());
  }

  // Navigation vers l'édition d'une leçon existante
  void _navigateToEditLesson(Lesson lesson) {
    if (_course == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLessonFormPage(
          courseId: _course!.id,
          isEditing: true,
          lesson: lesson,
        ),
      ),
    ).then((_) => _loadCourseDetails());
  }

  // Navigation vers l'édition du quiz
  void _navigateToEditQuiz() {
    if (_course == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminQuizFormPage(
          courseId: _course!.id,
          quiz: _course!.quiz,
        ),
      ),
    ).then((_) => _loadCourseDetails());
  }

  // Suppression d'une leçon
  Future<void> _deleteLesson(Lesson lesson) async {
    if (_course == null) return;

    // Confirmation de suppression
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Confirmation de suppression',
      message: 'Êtes-vous sûr de vouloir supprimer la leçon "${lesson.title}" ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (!confirm) return;

    try {
      final success = await _courseService.deleteLesson(_course!.id, lesson.id);

      if (success) {
        // Afficher un message de succès
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'La leçon "${lesson.title}" a été supprimée avec succès.',
            backgroundColor: Colors.green,
          );
        }

        // Recharger les détails du cours
        _loadCourseDetails();
      } else {
        // Afficher un message d'erreur
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Échec de la suppression de la leçon.',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      // Afficher un message d'erreur
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Construction de l'onglet d'informations générales
  Widget _buildInfoTab() {
    if (_course == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du cours
          if (_course!.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _course!.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Titre et niveau
          Row(
            children: [
              Expanded(
                child: Text(
                  _course!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getLevelColor(_course!.level).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getLevelColor(_course!.level),
                  ),
                ),
                child: Text(
                  AppUtils.translateLevel(_course!.level),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(_course!.level),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Catégorie
          Row(
            children: [
              const Icon(
                Icons.category,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Catégorie:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(_category?.name ?? 'Non spécifiée'),
            ],
          ),
          const SizedBox(height: 8),

          // Durée
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Durée:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(AppUtils.formatDuration(_course!.durationMinutes)),
            ],
          ),
          const SizedBox(height: 8),

          // Nombre de leçons
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Leçons:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text('${_course!.lessons.length} leçon(s)'),
            ],
          ),
          const SizedBox(height: 8),

          // Nombre de questions de quiz
          Row(
            children: [
              const Icon(
                Icons.quiz,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Questions de quiz:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text('${_course!.quiz.questions.length} question(s)'),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _course!.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Vidéo
          if (_course!.videoUrl.isNotEmpty) ...[
            const Text(
              'Lien vidéo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Dans une vraie application, ouvrir le lien
                AppUtils.showSnackBar(
                  context,
                  'Lien vidéo: ${_course!.videoUrl}',
                );
              },
              child: Text(
                _course!.videoUrl,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // PDF
          if (_course!.pdfUrl.isNotEmpty) ...[
            const Text(
              'Document PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Dans une vraie application, ouvrir le PDF
                AppUtils.showSnackBar(
                  context,
                  'Fichier PDF: ${_course!.pdfUrl}',
                );
              },
              child: Text(
                _course!.pdfUrl,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Bouton d'édition
          if (_authService.currentAdmin?.hasPermission('update:course') == true) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToEditCourse,
                icon: const Icon(Icons.edit),
                label: const Text('Modifier le cours'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Construction de l'onglet des leçons
  Widget _buildLessonsTab() {
    if (_course == null) return const SizedBox.shrink();

    // Trier les leçons par ordre
    final sortedLessons = List<Lesson>.from(_course!.lessons)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Column(
      children: [
        // Bouton d'ajout de leçon
        if (_authService.currentAdmin?.hasPermission('create:lesson') == true) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddLesson,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une leçon'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],

        // Liste des leçons
        Expanded(
          child: sortedLessons.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune leçon n\'a encore été ajoutée à ce cours.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedLessons.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final lesson = sortedLessons[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      AppUtils.truncateText(lesson.content, 60),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppUtils.formatDuration(lesson.durationMinutes),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (lesson.videoUrl != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.videocam,
                            size: 14,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Vidéo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_authService.currentAdmin?.hasPermission('update:lesson') == true)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Modifier',
                        onPressed: () => _navigateToEditLesson(lesson),
                      ),
                    if (_authService.currentAdmin?.hasPermission('delete:lesson') == true)
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: 'Supprimer',
                        onPressed: () => _deleteLesson(lesson),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Construction de l'onglet du quiz
  Widget _buildQuizTab() {
    if (_course == null) return const SizedBox.shrink();

    final quiz = _course!.quiz;

    return Column(
      children: [
        // En-tête du quiz
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.quiz,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quiz.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${quiz.questions.length} question(s)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bouton d'édition du quiz
                  if (_authService.currentAdmin?.hasPermission('update:quiz') == true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToEditQuiz,
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier le quiz'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Liste des questions
        Expanded(
          child: quiz.questions.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune question n\'a encore été ajoutée au quiz.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quiz.questions.length,
            itemBuilder: (context, index) {
              final question = quiz.questions[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Numéro et texte de la question
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Badge du type de question
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.type == QuestionType.multipleChoice
                              ? 'Choix multiple'
                              : 'Vrai/Faux',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Options
                      ...List.generate(
                        question.options.length,
                            (optionIndex) {
                          final isCorrect = optionIndex == question.correctOptionIndex;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green[50]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCorrect
                                    ? Colors.green
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.grey[400],
                                  ),
                                  child: Center(
                                    child: isCorrect
                                        ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                        : Text(
                                      String.fromCharCode(65 + optionIndex),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    question.options[optionIndex],
                                    style: TextStyle(
                                      fontWeight: isCorrect
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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
              );
            },
          ),
        ),
      ],
    );
  }

  // Méthode utilitaire pour obtenir la couleur en fonction du niveau
  Color _getLevelColor(String level) {
    switch (level) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_course?.title ?? 'Détails du cours'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: !_isLoading && _errorMessage == null
            ? TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Informations'),
            Tab(text: 'Leçons'),
            Tab(text: 'Quiz'),
          ],
        )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourseDetails,
            tooltip: 'Actualiser',
          ),
        ],
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
              onPressed: _loadCourseDetails,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildLessonsTab(),
          _buildQuizTab(),
        ],
      ),
    );
  }
}