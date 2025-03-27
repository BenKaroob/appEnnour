import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import 'admin_login_page.dart';
import 'admin_course_page.dart';
import 'admin_users_page.dart';
import 'admin_categories_page.dart';
import 'admin_admins_page.dart';
import 'admin_activity_page.dart';
import 'admin_statistics_page.dart';
import 'admin_quizzes_page.dart';
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminAuthService _authService = AdminAuthService();
  final ActivityLogService _activityLogService = ActivityLogService();
  final AdminCourseService _courseService = AdminCourseService();
  final AdminUserService _userService = AdminUserService();

  bool _isLoading = true;
  Admin? _admin;
  List<ActivityLog> _recentActivities = [];
  Map<String, dynamic> _courseStats = {};
  Map<String, dynamic> _userStats = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Chargement des données du tableau de bord
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer l'admin connecté
      final admin = _authService.currentAdmin;

      if (admin == null) {
        // Rediriger vers la page de connexion si non authentifié
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminLoginPage()),
          );
        }
        return;
      }

      // Charger les activités récentes
      final recentActivities = await _activityLogService.getRecentActivityLogs();

      // Charger les statistiques si les permissions le permettent
      Map<String, dynamic> courseStats = {};
      Map<String, dynamic> userStats = {};

      if (admin.hasPermission('read:stats')) {
        // Utiliser 'all' comme valeur par défaut pour afficher toutes les statistiques
        courseStats = await _courseService.getCourseStatistics('all');
        userStats = await _userService.getUserStatistics('all');
      }

      setState(() {
        _admin = admin;
        _recentActivities = recentActivities;
        _courseStats = courseStats;
        _userStats = userStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: $e';
        _isLoading = false;
      });
      print('Erreur de chargement du tableau de bord: $e');
    }
  }

  // Déconnexion
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginPage()),
      );
    }
  }

  // Navigation vers une section du backoffice
  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      // Recharger les données après retour à cette page
      _loadDashboardData();
    });
  }

  // Widget pour la carte de statistique
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une carte de menu
  Widget _buildMenuCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour une activité récente
  Widget _buildActivityItem(ActivityLog activity) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(int.parse(activity.actionColor.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            activity.actionIcon,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      title: Text(activity.description),
      subtitle: Row(
        children: [
          Text(
            '${activity.displayTargetType} • ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            _formatDateTime(activity.timestamp),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Afficher les détails de l'activité dans une boîte de dialogue
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(activity.description),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_formatDateTimeFull(activity.timestamp)}'),
                const SizedBox(height: 8),
                Text('Administrateur: ${activity.adminName}'),
                const SizedBox(height: 8),
                Text('Action: ${activity.action}'),
                const SizedBox(height: 8),
                Text('Type: ${activity.displayTargetType}'),
                if (activity.targetId != null) ...[
                  const SizedBox(height: 8),
                  Text('ID cible: ${activity.targetId}'),
                ],
                if (activity.details != null && activity.details!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Détails:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...activity.details!.entries.map(
                        (e) => Text('${e.key}: ${e.value}'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Formatage de la date pour l'affichage
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  // Formatage complet de la date
  String _formatDateTimeFull(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord administrateur'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Actualiser',
          ),
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
              onPressed: _loadDashboardData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec informations de l'admin
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        _admin!.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue, ${_admin!.name}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _admin!.displayRole,
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _admin!.role == 'super_admin'
                            ? Colors.amber[100]
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _admin!.role == 'super_admin'
                              ? Colors.amber
                              : Colors.blue,
                        ),
                      ),
                      child: Text(
                        _admin!.role == 'super_admin'
                            ? 'Accès complet'
                            : 'Accès limité',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _admin!.role == 'super_admin'
                              ? Colors.amber[800]
                              : Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques principales
            if (_admin!.hasPermission('read:stats') &&
                _courseStats.isNotEmpty &&
                _userStats.isNotEmpty) ...[
              const Text(
                'Statistiques globales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    'Cours',
                    _courseStats['totalCourses'].toString(),
                    Icons.book,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    'Utilisateurs',
                    _userStats['totalUsers'].toString(),
                    Icons.people,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Leçons',
                    _courseStats['totalLessons'].toString(),
                    Icons.school,
                    Colors.amber[700]!,
                  ),
                  _buildStatCard(
                    'Score moyen',
                    '${_userStats['averageScore'].toStringAsFixed(1)}%',
                    Icons.analytics,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Menu principal
            const Text(
              'Gestion des contenus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Dans la grille des options du menu (GridView.count)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (_admin!.hasPermission('read:course'))
                  _buildMenuCard(
                    'Cours',
                    'Gérer les cours et leur contenu',
                    Icons.book,
                        () => _navigateTo(const AdminCourseFormPage(isEditing: false)), // Utiliser cette page en attendant
                  ),
                if (_admin!.hasPermission('read:user'))
                  _buildMenuCard(
                    'Utilisateurs',
                    'Gérer les comptes utilisateurs',
                    Icons.people,
                        () => _navigateTo(const AdminUsersPage()),
                  ),
                // AJOUTEZ CETTE CARTE POUR LES QUIZ
                if (_admin!.hasPermission('read:course'))
                  _buildMenuCard(
                    'Quiz',
                    'Gérer les quiz des cours',
                    Icons.quiz,
                        () => _navigateTo(const AdminQuizzesPage()),
                  ),
                if (_admin!.hasPermission('read:category'))
                  _buildMenuCard(
                    'Catégories',
                    'Gérer les catégories de cours',
                    Icons.category,
                        () => _navigateTo(const AdminCategoriesPage()),
                  ),
                if (_admin!.role == 'super_admin')
                  _buildMenuCard(
                    'Administrateurs',
                    'Gérer les comptes admin',
                    Icons.admin_panel_settings,
                        () => _navigateTo(const AdminAdminsPage()),
                  ),
                _buildMenuCard(
                  'Activités',
                  'Journal des activités administratives',
                  Icons.history,
                      () => _navigateTo(const AdminActivityPage()),
                ),
                if (_admin!.hasPermission('read:stats'))
                  _buildMenuCard(
                    'Statistiques',
                    'Voir les statistiques détaillées',
                    Icons.analytics,
                        () => _navigateTo(const AdminStatisticsPage()),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Activités récentes
            const Text(
              'Activités récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: _recentActivities.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Aucune activité récente',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              )
                  : Column(
                children: [
                  ...List.generate(
                    _recentActivities.length > 5 ? 5 : _recentActivities.length,
                        (index) => _buildActivityItem(_recentActivities[index]),
                  ),

                  // Bouton pour voir toutes les activités
                  if (_recentActivities.length > 5)
                    TextButton(
                      onPressed: () => _navigateTo(const AdminActivityPage()),
                      child: const Text('Voir toutes les activités'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}