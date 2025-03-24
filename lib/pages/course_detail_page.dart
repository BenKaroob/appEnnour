import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../utils/index.dart';
import '../widgets/index.dart';

// Page de détail d'un cours spécifique
class CourseDetailPage extends StatefulWidget {
  final String courseId;

  const CourseDetailPage({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final CourseService _courseService = CourseService();
  final UserService _userService = UserService();
  final QuizService _quizService = QuizService();

  bool _isLoading = true;
  Course? _course;
  String? _errorMessage;
  int? _quizScore;
  bool _courseCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
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

      // Vérifier si l'utilisateur a déjà fait le quiz
      final hasCompletedQuiz = await _quizService.hasCompletedQuiz(course.quiz.id);
      int? quizScore;

      if (hasCompletedQuiz) {
        quizScore = await _quizService.getUserQuizScore(course.quiz.id);
      }

      // Vérifier si le cours est marqué comme complété
      final courseCompleted = await _userService.hasCompletedCourse(course.id);

      setState(() {
        _course = course;
        _quizScore = quizScore;
        _courseCompleted = courseCompleted;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du cours';
        _isLoading = false;
      });
      print('Erreur de chargement du cours: $e');
    }
  }

  // Navigation vers la page de quiz
  void _navigateToQuiz() {
    if (_course == null) return;

    AppRoutes.navigateToQuiz(
      context,
      _course!.id,
      _course!.quiz.id,
    );
  }

  // Construction de la section d'en-tête avec image et info
  Widget _buildHeader() {
    if (_course == null) return const SizedBox.shrink();

    return Stack(
      children: [
        // Image du cours
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            _course!.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.accentColor.withOpacity(0.2),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            },
          ),
        ),

        // Overlay de couleur dégradé
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),

        // Informations du cours
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de niveau
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppUtils.translateLevel(_course!.level),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Titre du cours
              Text(
                _course!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),

              // Durée et nombre de leçons
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppUtils.formatDuration(_course!.durationMinutes),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.list_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_course!.lessons.length} leçons',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Badge de cours complété
        if (_courseCompleted)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Complété',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Construction de la section de description
  Widget _buildDescription() {
    if (_course == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À propos de ce cours',
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
        ],
      ),
    );
  }

  // Construction de la liste des leçons
  Widget _buildLessonsList() {
    if (_course == null) return const SizedBox.shrink();

    // Trier les leçons par ordre
    final lessons = List<Lesson>.from(_course!.lessons)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: const Text(
            'Contenu du cours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final lesson = lessons[index];

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: 4,
              ),
              child: LessonListItem(
                lesson: lesson,
                index: index,
                isActive: index == 0, // Première leçon active par défaut
                isCompleted: _courseCompleted, // Toutes marquées comme complétées si le cours l'est
                onTap: () {
                  // Pour le prototype, on ne navigue pas vers la leçon
                  // À implémenter dans une version future
                  AppUtils.showSnackBar(
                    context,
                    'Ouverture de la leçon "${lesson.title}"',
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // Construction du bloc de quiz
  Widget _buildQuizBlock() {
    if (_course == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.quiz,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _course!.quiz.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _course!.quiz.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Score du quiz s'il a été fait
          if (_quizScore != null) ...[
            Row(
              children: [
                CircularProgressWidget(
                  progress: _quizScore!.toDouble(),
                  size: 60,
                  strokeWidth: 6,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votre score',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_quizScore!}% - ${AppConstants.getQuizResultMessage(_quizScore!)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppUtils.getScoreColor(_quizScore!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Bouton pour démarrer ou refaire le quiz
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToQuiz,
              icon: Icon(
                _quizScore != null ? Icons.refresh : Icons.play_arrow,
              ),
              label: Text(
                _quizScore != null ? 'Refaire le quiz' : 'Commencer le quiz',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construction du bloc de ressources supplémentaires
  Widget _buildResourcesBlock() {
    if (_course == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ressources supplémentaires',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Vidéo du cours
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.video_library,
                color: AppTheme.primaryColor,
              ),
            ),
            title: const Text('Vidéo explicative'),
            subtitle: const Text('Regarder la vidéo du cours'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Pour le prototype, afficher un message
              AppUtils.showSnackBar(
                context,
                'Ouverture de la vidéo (mockée)',
              );
            },
          ),

          // Fiche PDF
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
              ),
            ),
            title: const Text('Fiche de révision'),
            subtitle: const Text('Télécharger la fiche PDF'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Pour le prototype, afficher un message
              AppUtils.showSnackBar(
                context,
                'Téléchargement du PDF (mocké)',
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: _course?.title ?? 'Détail du cours',
        showBackButton: true,
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
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec image et informations
            _buildHeader(),

            // Description du cours
            _buildDescription(),

            // Bloc de quiz
            _buildQuizBlock(),

            // Liste des leçons
            _buildLessonsList(),

            // Ressources supplémentaires
            _buildResourcesBlock(),

            // Espace en bas pour le scroll
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}