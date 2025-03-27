import '../models/index.dart';
import 'mock_admin_data_service.dart';
import 'admin_auth_service.dart';
import 'activity_log_service.dart';

// Service pour gérer les utilisateurs dans le backoffice
class AdminUserService {
  final MockAdminDataService _mockAdminDataService = MockAdminDataService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  final ActivityLogService _activityLogService = ActivityLogService();

  // Singleton pattern
  static final AdminUserService _instance = AdminUserService._internal();
  factory AdminUserService() => _instance;
  AdminUserService._internal();

  // Récupère tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:user')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAdminDataService.dataService.users;
  }

  // Récupère un utilisateur par son ID
  Future<User?> getUserById(String userId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:user')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAdminDataService.dataService.findUserById(userId);
  }

  // Recherche des utilisateurs selon des critères
  Future<List<User>> searchUsers({
    String? query,
    String? role,
    bool? hasCompletedCourses,
  }) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:user')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Récupérer tous les utilisateurs
    final users = _mockAdminDataService.dataService.users;

    // Filtrer selon les critères
    return users.where((user) {
      // Filtrer par texte de recherche
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        final nameMatches = user.name.toLowerCase().contains(queryLower);
        final emailMatches = user.email.toLowerCase().contains(queryLower);
        if (!nameMatches && !emailMatches) {
          return false;
        }
      }

      // Filtrer par rôle
      if (role != null && user.role != role) {
        return false;
      }

      // Filtrer par achèvement de cours
      if (hasCompletedCourses != null) {
        final hasCompleted = user.completedCourseIds.isNotEmpty;
        if (hasCompletedCourses != hasCompleted) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Crée un nouvel utilisateur
  Future<User> createUser(User user) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('create:user')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'create',
      targetType: 'user',
      targetId: user.id,
      description: 'Création de l\'utilisateur "${user.name}"',
      details: {
        'email': user.email,
        'role': user.role,
      },
    );

    // Dans un vrai système, l'utilisateur serait persisté dans une base de données
    // Pour le prototype, on simule simplement un succès
    return user;
  }

  // Met à jour un utilisateur existant
  Future<User> updateUser(User user) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:user')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'update',
      targetType: 'user',
      targetId: user.id,
      description: 'Mise à jour de l\'utilisateur "${user.name}"',
    );

    // Dans un vrai système, l'utilisateur serait mis à jour dans une base de données
    // Pour le prototype, on simule simplement un succès
    return user;
  }

  // Supprime un utilisateur
  Future<bool> deleteUser(String userId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('delete:user')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si l'utilisateur existe
    final user = _mockAdminDataService.dataService.findUserById(userId);
    if (user == null) {
      return false;
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'delete',
      targetType: 'user',
      targetId: userId,
      description: 'Suppression de l\'utilisateur "${user.name}"',
    );

    // Dans un vrai système, l'utilisateur serait supprimé de la base de données
    // Pour le prototype, on simule simplement un succès
    return true;
  }

  // Réinitialise le mot de passe d'un utilisateur
  Future<bool> resetUserPassword(String userId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:user')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si l'utilisateur existe
    final user = _mockAdminDataService.dataService.findUserById(userId);
    if (user == null) {
      return false;
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'update',
      targetType: 'user',
      targetId: userId,
      description: 'Réinitialisation du mot de passe pour l\'utilisateur "${user.name}"',
    );

    // Dans un vrai système, un email serait envoyé à l'utilisateur avec un lien de réinitialisation
    // Pour le prototype, on simule simplement un succès
    return true;
  }

  // Obtient les progrès d'un utilisateur
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:user')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si l'utilisateur existe
    final user = _mockAdminDataService.dataService.findUserById(userId);
    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 500));

    // Récupérer les cours complétés
    final completedCourses = <Course>[];
    for (final courseId in user.completedCourseIds) {
      final course = _mockAdminDataService.dataService.findCourseById(courseId);
      if (course != null) {
        completedCourses.add(course);
      }
    }

    // Calculer la progression globale
    final overallProgress = user.overallProgress;

    // Obtenir les scores de quiz
    final quizScores = user.quizScores;

    // Regrouper les cours complétés par catégorie
    final completedByCategory = <String, int>{};
    for (final course in completedCourses) {
      final category = _mockAdminDataService.dataService.findCategoryById(course.categoryId);
      if (category != null) {
        completedByCategory[category.name] = (completedByCategory[category.name] ?? 0) + 1;
      }
    }

    // Retourner les données de progression
    return {
      'overallProgress': overallProgress,
      'completedCoursesCount': completedCourses.length,
      'quizScores': quizScores,
      'averageQuizScore': quizScores.isEmpty
          ? 0
          : quizScores.values.reduce((a, b) => a + b) / quizScores.length,
      'completedByCategory': completedByCategory,
    };
  }

  // Obtient des statistiques sur les utilisateurs avec filtrage par période
  Future<Map<String, dynamic>> getUserStatistics(String timeRange) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:stats')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Récupérer tous les utilisateurs
    final users = _mockAdminDataService.dataService.users;

    // Filtrer les utilisateurs selon la période (dans un vrai système)
    // Ici, nous simulons simplement des données différentes selon la période
    int studentCount = 0;
    int parentCount = 0;
    int teacherCount = 0;
    int activeUsers = 0;
    double averageScore = 0.0;

    switch (timeRange) {
      case 'week':
        studentCount = 234;
        parentCount = 158;
        teacherCount = 12;
        activeUsers = 98;
        averageScore = 75.3;
        break;
      case 'month':
        studentCount = 254;
        parentCount = 168;
        teacherCount = 14;
        activeUsers = 156;
        averageScore = 76.8;
        break;
      case 'year':
        studentCount = 320;
        parentCount = 195;
        teacherCount = 18;
        activeUsers = 245;
        averageScore = 78.2;
        break;
      case 'all':
      default:
        studentCount = 342;
        parentCount = 215;
        teacherCount = 19;
        activeUsers = 310;
        averageScore = 78.5;
        break;
    }

    // Nombre d'utilisateurs par rôle (dans un vrai système, ces valeurs seraient calculées)
    final usersByRole = {
      'étudiant': studentCount,
      'parent': parentCount,
      'professeur': teacherCount,
      'admin': 3,
    };

    // Retourner les statistiques
    return {
      'totalUsers': users.length,
      'usersByRole': usersByRole,
      'studentCount': studentCount,
      'parentCount': parentCount,
      'teacherCount': teacherCount,
      'adminCount': 3,
      'activeUsers': activeUsers,
      'newUsers': timeRange == 'week' ? 23 : (timeRange == 'month' ? 76 : 234),
      'averageScore': averageScore,
      'maleUsers': 215,
      'femaleUsers': 192,
    };
  }

  // Obtient des statistiques sur l'activité des utilisateurs
  Future<Map<String, dynamic>> getActivityStatistics(String timeRange) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:stats')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 700));

    // Dans un vrai système, ces données seraient calculées à partir des logs d'activité
    // ou des interactions enregistrées en base de données. Ici, nous simulons des données.

    // Les utilisateurs les plus actifs - simulés
    final List<Map<String, dynamic>> mostActiveUsers = [
      {'id': 'user1', 'name': 'Ahmed B.', 'activity': 85, 'loginCount': 42, 'completedLessons': 28},
      {'id': 'user2', 'name': 'Fatima Z.', 'activity': 78, 'loginCount': 38, 'completedLessons': 25},
      {'id': 'user3', 'name': 'Youssef M.', 'activity': 65, 'loginCount': 30, 'completedLessons': 18},
      {'id': 'user4', 'name': 'Amina K.', 'activity': 60, 'loginCount': 28, 'completedLessons': 15},
      {'id': 'user5', 'name': 'Omar S.', 'activity': 55, 'loginCount': 25, 'completedLessons': 12},
    ];

    // Ajuster les données en fonction de la période
    if (timeRange == 'week') {
      // Pour la semaine, l'activité est généralement moins élevée
      for (var user in mostActiveUsers) {
        user['activity'] = (user['activity'] as int) - 10;
        user['loginCount'] = ((user['loginCount'] as int) * 0.3).round();
        user['completedLessons'] = ((user['completedLessons'] as int) * 0.2).round();
      }
    } else if (timeRange == 'month') {
      // Pour le mois, activité moyenne
      for (var user in mostActiveUsers) {
        user['activity'] = (user['activity'] as int) - 5;
        user['loginCount'] = ((user['loginCount'] as int) * 0.7).round();
        user['completedLessons'] = ((user['completedLessons'] as int) * 0.6).round();
      }
    }

    // Activité par jour de la semaine - simulée
    final List<Map<String, dynamic>> activityByDay = [
      {'day': 'Lun', 'count': 87, 'lessons': 42, 'quizzes': 18},
      {'day': 'Mar', 'count': 65, 'lessons': 35, 'quizzes': 12},
      {'day': 'Mer', 'count': 92, 'lessons': 48, 'quizzes': 22},
      {'day': 'Jeu', 'count': 78, 'lessons': 40, 'quizzes': 16},
      {'day': 'Ven', 'count': 53, 'lessons': 28, 'quizzes': 10},
      {'day': 'Sam', 'count': 45, 'lessons': 22, 'quizzes': 8},
      {'day': 'Dim', 'count': 29, 'lessons': 15, 'quizzes': 5},
    ];

    // Calculs du temps moyen d'activité et du nombre total de connexions selon la période
    int averageActivityTime;
    int totalLogins;

    switch (timeRange) {
      case 'week':
        averageActivityTime = 42;
        totalLogins = 478;
        break;
      case 'month':
        averageActivityTime = 156;
        totalLogins = 1856;
        break;
      case 'year':
        averageActivityTime = 342;
        totalLogins = 6785;
        break;
      case 'all':
      default:
        averageActivityTime = 423;
        totalLogins = 8234;
        break;
    }

    // Activités par type (cours, quiz, etc.) - simulées
    final Map<String, int> activityByType = {
      'course': timeRange == 'week' ? 235 : (timeRange == 'month' ? 876 : 3254),
      'quiz': timeRange == 'week' ? 128 : (timeRange == 'month' ? 432 : 1765),
      'practice': timeRange == 'week' ? 87 : (timeRange == 'month' ? 328 : 1345),
      'forum': timeRange == 'week' ? 45 : (timeRange == 'month' ? 178 : 876),
    };

    // Heures d'activité les plus populaires - simulées
    final List<Map<String, dynamic>> peakHours = [
      {'hour': '08:00', 'count': 56},
      {'hour': '10:00', 'count': 78},
      {'hour': '14:00', 'count': 92},
      {'hour': '16:00', 'count': 124},
      {'hour': '18:00', 'count': 108},
      {'hour': '20:00', 'count': 86},
      {'hour': '22:00', 'count': 45},
    ];

    return {
      'mostActiveUsers': mostActiveUsers,
      'averageActivityTime': averageActivityTime,
      'totalLogins': totalLogins,
      'activityByDay': activityByDay,
      'activityByType': activityByType,
      'peakHours': peakHours,
      // Indicateurs de progression
      'totalCompletedLessons': timeRange == 'week' ? 876 : (timeRange == 'month' ? 3456 : 12543),
      'totalQuizAttempts': timeRange == 'week' ? 423 : (timeRange == 'month' ? 1532 : 5678),
      'averageCompletionTime': timeRange == 'week' ? 25 : (timeRange == 'month' ? 22 : 20),
    };
  }

  // Met à jour le statut d'un utilisateur (actif/inactif)
  Future<User> updateUserStatus(String userId, bool isActive) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:user')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si l'utilisateur existe
    final user = _mockAdminDataService.dataService.findUserById(userId);
    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 500));

    // Créer un utilisateur mis à jour avec le nouveau statut
    final updatedUser = user.copyWith(isActive: isActive);

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'update',
      targetType: 'user',
      targetId: userId,
      description: 'Modification du statut de l\'utilisateur "${user.name}" en ${isActive ? 'actif' : 'inactif'}',
    );

    // Dans un vrai système, l'utilisateur serait mis à jour dans une base de données
    // Pour le prototype, on simule simplement un succès
    return updatedUser;
  }

  // Assigne un cours à un utilisateur
  Future<bool> assignCourseToUser(String userId, String courseId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:user')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si l'utilisateur et le cours existent
    final user = _mockAdminDataService.dataService.findUserById(userId);
    final course = _mockAdminDataService.dataService.findCourseById(courseId);

    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }
    if (course == null) {
      throw Exception('Cours non trouvé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'assign',
      targetType: 'course',
      targetId: courseId,
      details: {'userId': userId},
      description: 'Attribution du cours "${course.title}" à l\'utilisateur "${user.name}"',
    );

    // Dans un vrai système, l'association serait enregistrée dans une base de données
    // Pour le prototype, on simule simplement un succès
    return true;
  }

  // Exporte les données utilisateur (pour reporting)
  Future<List<Map<String, dynamic>>> exportUserData(List<String> fields) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('export:data')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 1000));

    // Récupérer tous les utilisateurs
    final users = _mockAdminDataService.dataService.users;

    // Filtrer les champs demandés
    final exportData = users.map((user) {
      final Map<String, dynamic> userData = {};
      for (final field in fields) {
        switch (field) {
          case 'id':
            userData[field] = user.id;
            break;
          case 'name':
            userData[field] = user.name;
            break;
          case 'email':
            userData[field] = user.email;
            break;
          case 'role':
            userData[field] = user.role;
            break;
          case 'isActive':
            userData[field] = user.isActive;
            break;
          case 'registrationDate':
            userData[field] = user.creationDate?.toString();
            break;
          case 'lastLoginDate':
            userData[field] = user.lastLoginDate?.toString();
            break;
          case 'completedCourseCount':
            userData[field] = user.completedCourseIds.length;
            break;
          case 'averageQuizScore':
            userData[field] = user.quizScores.isEmpty
                ? 0
                : user.quizScores.values.reduce((a, b) => a + b) / user.quizScores.length;
            break;
        }
      }
      return userData;
    }).toList();

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'export',
      targetType: 'user',
      description: 'Export des données utilisateurs',
      details: {'fields': fields},
    );

    return exportData;
  }
}