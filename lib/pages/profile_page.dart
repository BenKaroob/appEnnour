import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../utils/index.dart';
import '../widgets/index.dart';

// Page de profil utilisateur
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final CourseService _courseService = CourseService();
  final QuizService _quizService = QuizService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  User? _user;
  List<Course> _completedCourses = [];
  Map<String, int> _quizScores = {};
  double _overallProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Chargement des informations de profil
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer l'utilisateur actuel
      final user = await _userService.getCurrentUser();

      if (user == null) {
        setState(() {
          _errorMessage = 'Utilisateur non connecté';
          _isLoading = false;
        });
        return;
      }

      // Récupérer les cours complétés
      final completedCourses = await _userService.getCompletedCourses();

      // Récupérer les scores de quiz
      final quizScores = await _quizService.getUserQuizScores();

      // Calculer la progression globale
      final overallProgress = await _userService.getUserOverallProgress();

      setState(() {
        _user = user;
        _completedCourses = completedCourses;
        _quizScores = quizScores;
        _overallProgress = overallProgress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du profil';
        _isLoading = false;
      });
      print('Erreur de chargement du profil: $e');
    }
  }

  // Navigation vers le détail d'un cours
  void _navigateToCourseDetail(String courseId) {
    AppRoutes.navigateToCourseDetail(context, courseId);
  }

  // Déconnexion de l'utilisateur
  Future<void> _handleLogout() async {
    final bool confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Déconnexion',
      cancelText: 'Annuler',
    );

    if (confirm) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // Construction de l'en-tête du profil
  Widget _buildProfileHeader() {
    if (_user == null) return const SizedBox.shrink();

    // Créer les initiales pour l'avatar si pas d'image
    final initials = _user!.name.isNotEmpty
        ? _user!.name.split(' ').map((e) => e[0]).take(2).join()
        : '?';

    // Couleur générée à partir du nom
    final avatarColor = AppUtils.getColorFromText(_user!.name);

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar et badge de rôle
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Avatar (image ou initiales)
              CircleAvatar(
                radius: 50,
                backgroundColor: _user!.profileImageUrl.isEmpty
                    ? avatarColor
                    : Colors.transparent,
                backgroundImage: _user!.profileImageUrl.isNotEmpty
                    ? AssetImage(_user!.profileImageUrl)
                    : null,
                child: _user!.profileImageUrl.isEmpty
                    ? Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),

              // Badge de rôle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _user!.role == 'student'
                      ? AppTheme.secondaryColor
                      : Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  _user!.role == 'student' ? 'Élève' : 'Parent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nom et email
          Text(
            _user!.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Indicateur de progression globale
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Progression globale',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                CircularProgressWidget(
                  progress: _overallProgress,
                  size: 100,
                  strokeWidth: 10,
                  progressColor: AppTheme.secondaryColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_overallProgress.round()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Text(
                        'complété',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construction de la section des cours complétés
  Widget _buildCompletedCourses() {
    if (_completedCourses.isEmpty) {
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
          children: [
            const Text(
              'Cours complétés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Vous n\'avez pas encore complété de cours',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
              child: const Text('Explorer les cours'),
            ),
          ],
        ),
      );
    }

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
            'Cours complétés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Liste des cours complétés
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _completedCourses.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final course = _completedCourses[index];
              final quizScore = _quizScores[course.quiz.id];

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: quizScore != null
                    ? Text(
                  'Score: ${quizScore}%',
                  style: TextStyle(
                    color: AppUtils.getScoreColor(quizScore),
                    fontWeight: FontWeight.w500,
                  ),
                )
                    : const Text('Complété'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToCourseDetail(course.id),
              );
            },
          ),
        ],
      ),
    );
  }

  // Construction de la section des statistiques
  Widget _buildStatistics() {
    final totalCourses = _completedCourses.length;
    final averageScore = _quizScores.isEmpty
        ? 0
        : _quizScores.values.reduce((a, b) => a + b) / _quizScores.length;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
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
            'Mes statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Statistiques en grille
          Row(
            children: [
              // Nombre de cours complétés
              Expanded(
                child: _buildStatItem(
                  'Cours terminés',
                  totalCourses.toString(),
                  Icons.school,
                  AppTheme.primaryColor,
                ),
              ),

              // Score moyen des quiz
              Expanded(
                child: _buildStatItem(
                  'Score moyen',
                  '${averageScore.round()}%',
                  Icons.analytics,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Construction d'un élément de statistique
  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
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
        title: 'Mon profil',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Déconnexion',
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
              onPressed: _loadUserProfile,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête du profil
            _buildProfileHeader(),

            // Statistiques
            _buildStatistics(),

            // Cours complétés
            _buildCompletedCourses(),

            // Espace en bas pour le scroll
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}