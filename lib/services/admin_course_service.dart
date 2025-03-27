import '../models/index.dart';
import 'mock_admin_data_service.dart';
import 'admin_auth_service.dart';
import 'activity_log_service.dart';

// Service pour gérer les cours dans le backoffice
class AdminCourseService {
  final MockAdminDataService _mockAdminDataService = MockAdminDataService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  final ActivityLogService _activityLogService = ActivityLogService();

  // Singleton pattern
  static final AdminCourseService _instance = AdminCourseService._internal();
  factory AdminCourseService() => _instance;
  AdminCourseService._internal();

  // Récupère toutes les catégories
  Future<List<Category>> getCategories() async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:category')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAdminDataService.dataService.categories;
  }


  // Récupère un catégorie par son ID
  Future<Category?> getCategoryById(String categoryId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:category')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAdminDataService.dataService.findCategoryById(categoryId);
  }

  // Récupère tous les cours
  Future<List<Course>> getAllCourses() async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:course')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAdminDataService.dataService.courses;
  }

  // Récupère un cours par son ID
  Future<Course?> getCourseById(String courseId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:all') &&
        !_adminAuthService.hasPermission('read:course')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAdminDataService.dataService.findCourseById(courseId);
  }

  // Crée une nouvelle catégorie
  Future<Category> createCategory(Category category) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('create:category')) {
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
      targetType: 'category',
      targetId: category.id,
      description: 'Création de la catégorie "${category.name}"',
    );

    // Dans un vrai système, la catégorie serait persistée dans une base de données
    // Pour le prototype, on simule simplement un succès
    return category;
  }

  // Met à jour une catégorie existante
  Future<Category> updateCategory(Category category) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:category')) {
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
      targetType: 'category',
      targetId: category.id,
      description: 'Mise à jour de la catégorie "${category.name}"',
    );

    // Dans un vrai système, la catégorie serait mise à jour dans une base de données
    // Pour le prototype, on simule simplement un succès
    return category;
  }

  // Supprime une catégorie
  Future<bool> deleteCategory(String categoryId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('delete:category')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si la catégorie existe
    final category = _mockAdminDataService.dataService.findCategoryById(categoryId);
    if (category == null) {
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
      targetType: 'category',
      targetId: categoryId,
      description: 'Suppression de la catégorie "${category.name}"',
    );

    // Dans un vrai système, la catégorie serait supprimée de la base de données
    // Pour le prototype, on simule simplement un succès
    return true;
  }

  // Crée un nouveau cours
  Future<Course> createCourse(Course course) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('create:course')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 1000));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'create',
      targetType: 'course',
      targetId: course.id,
      description: 'Création du cours "${course.title}"',
      details: {
        'categoryId': course.categoryId,
        'level': course.level,
      },
    );

    // Dans un vrai système, le cours serait persisté dans une base de données
    // Pour le prototype, on simule simplement un succès
    return course;
  }

  // Met à jour un cours existant
  Future<Course> updateCourse(Course course) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:course')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 1000));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'update',
      targetType: 'course',
      targetId: course.id,
      description: 'Mise à jour du cours "${course.title}"',
    );

    // Dans un vrai système, le cours serait mis à jour dans une base de données
    // Pour le prototype, on simule simplement un succès
    return course;
  }

  // Supprime un cours
  Future<bool> deleteCourse(String courseId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('delete:course')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si le cours existe
    final course = _mockAdminDataService.dataService.findCourseById(courseId);
    if (course == null) {
      return false;
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 1000));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'delete',
      targetType: 'course',
      targetId: courseId,
      description: 'Suppression du cours "${course.title}"',
    );

    // Dans un vrai système, le cours serait supprimé de la base de données
    // Pour le prototype, on simule simplement un succès
    return true;
  }

  // Ajoute une leçon à un cours
  Future<Lesson> addLessonToCourse(String courseId, Lesson lesson) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:course') &&
        !_adminAuthService.hasPermission('create:lesson')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si le cours existe
    final course = _mockAdminDataService.dataService.findCourseById(courseId);
    if (course == null) {
      throw Exception('Cours non trouvé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'create',
      targetType: 'lesson',
      targetId: lesson.id,
      description: 'Ajout de la leçon "${lesson.title}" au cours "${course.title}"',
    );

    // Dans un vrai système, la leçon serait ajoutée au cours dans la base de données
    // Pour le prototype, on simule simplement un succès
    return lesson;
  }

  // Met à jour une leçon existante
  Future<Lesson> updateLesson(String courseId, Lesson lesson) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:lesson')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si le cours existe
    final course = _mockAdminDataService.dataService.findCourseById(courseId);
    if (course == null) {
      throw Exception('Cours non trouvé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'update',
      targetType: 'lesson',
      targetId: lesson.id,
      description: 'Mise à jour de la leçon "${lesson.title}" du cours "${course.title}"',
    );

    // Dans un vrai système, la leçon serait mise à jour dans la base de données
    // Pour le prototype, on simule simplement un succès
    return lesson;
  }

  // Supprime une leçon d'un cours
  Future<bool> deleteLesson(String courseId, String lessonId) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('delete:lesson')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si le cours existe
    final course = _mockAdminDataService.dataService.findCourseById(courseId);
    if (course == null) {
      throw Exception('Cours non trouvé');
    }

    // Trouver la leçon
    final lesson = course.lessons.firstWhere(
          (l) => l.id == lessonId,
      orElse: () => null as Lesson,
    );
    if (lesson == null) {
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
      targetType: 'lesson',
      targetId: lessonId,
      description: 'Suppression de la leçon "${lesson.title}" du cours "${course.title}"',
    );

    // Dans un vrai système, la leçon serait supprimée du cours dans la base de données
    // Pour le prototype, on simule simplement un succès
    return true;
  }

  // Met à jour un quiz pour un cours
  Future<Quiz> updateQuiz(String courseId, Quiz quiz) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('update:quiz')) {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si le cours existe
    final course = _mockAdminDataService.dataService.findCourseById(courseId);
    if (course == null) {
      throw Exception('Cours non trouvé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Enregistrer l'activité
    final admin = _adminAuthService.currentAdmin!;
    await _activityLogService.logActivity(
      adminId: admin.id,
      adminName: admin.name,
      action: 'update',
      targetType: 'quiz',
      targetId: quiz.id,
      description: 'Mise à jour du quiz "${quiz.title}" pour le cours "${course.title}"',
      details: {
        'questionCount': quiz.questions.length,
      },
    );

    // Dans un vrai système, le quiz serait mis à jour dans la base de données
    // Pour le prototype, on simule simplement un succès
    return quiz;
  }

  // Obtient des statistiques générales de la plateforme
  Future<Map<String, dynamic>> getGeneralStatistics(String timeRange) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:stats')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Logique différente selon la période sélectionnée
    // En réalité, cela impliquerait des filtres sur des dates dans la base de données
    int totalUsers = 0;
    int totalCourses = 0;
    int completedLessons = 0;
    int quizzesTaken = 0;

    switch (timeRange) {
      case 'week':
        totalUsers = 342;
        totalCourses = 28;
        completedLessons = 876;
        quizzesTaken = 423;
        break;
      case 'month':
        totalUsers = 407;
        totalCourses = 35;
        completedLessons = 2154;
        quizzesTaken = 987;
        break;
      case 'year':
        totalUsers = 497;
        totalCourses = 42;
        completedLessons = 8765;
        quizzesTaken = 3456;
        break;
      case 'all':
      default:
        totalUsers = 508;
        totalCourses = 45;
        completedLessons = 12543;
        quizzesTaken = 4567;
        break;
    }

    return {
      'totalUsers': totalUsers,
      'totalCourses': totalCourses,
      'completedLessons': completedLessons,
      'quizzesTaken': quizzesTaken,
    };
  }

  // Obtient des statistiques sur les cours
  Future<Map<String, dynamic>> getCourseStatistics(String timeRange) async {
    // Vérifier les permissions
    if (!_adminAuthService.hasPermission('read:stats')) {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Calculer les statistiques
    final courses = _mockAdminDataService.dataService.courses;
    final categories = _mockAdminDataService.dataService.categories;

    // Ajuster les statistiques selon la période
    double completionRate;
    int averageTime;
    int beginnerCourses;
    int advancedCourses;

    switch (timeRange) {
      case 'week':
        completionRate = 45.2;
        averageTime = 28;
        beginnerCourses = 18;
        advancedCourses = 10;
        break;
      case 'month':
        completionRate = 52.8;
        averageTime = 32;
        beginnerCourses = 20;
        advancedCourses = 15;
        break;
      case 'year':
        completionRate = 67.5;
        averageTime = 35;
        beginnerCourses = 25;
        advancedCourses = 20;
        break;
      case 'all':
      default:
        completionRate = 72.3;
        averageTime = 38;
        beginnerCourses = 28;
        advancedCourses = 17;
        break;
    }

    // Nombre total de cours par catégorie
    final coursesByCategory = <String, int>{};
    for (final category in categories) {
      coursesByCategory[category.name] = courses
          .where((course) => course.categoryId == category.id)
          .length;
    }

    // Nombre de cours par niveau
    final coursesByLevel = <String, int>{};
    final levels = courses.map((c) => c.level).toSet();
    for (final level in levels) {
      coursesByLevel[level] = courses
          .where((course) => course.level == level)
          .length;
    }

    // Nombre moyen de leçons par cours
    final totalLessons = courses.fold<int>(
      0,
          (sum, course) => sum + course.lessons.length,
    );
    final avgLessonsPerCourse = courses.isEmpty
        ? 0
        : totalLessons / courses.length;

    // Cours les plus populaires (simulation)
    final popularCourses = [
      {'title': 'L\'alphabet arabe', 'students': 120, 'id': 'course1'},
      {'title': 'Introduction à la récitation', 'students': 95, 'id': 'course2'},
      {'title': 'Mémorisation de sourates courtes', 'students': 80, 'id': 'course3'},
      {'title': 'Les pronoms personnels', 'students': 65, 'id': 'course4'},
      {'title': 'Les piliers de l\'Islam', 'students': 60, 'id': 'course5'},
    ];

    // Ajuster légèrement les statistiques selon la période
    if (timeRange == 'week') {
      for (var course in popularCourses) {
        course['students'] = ((course['students'] as int) * 0.7).round();
      }
    } else if (timeRange == 'month') {
      for (var course in popularCourses) {
        course['students'] = ((course['students'] as int) * 0.85).round();
      }
    }

    // Taux de complétion par catégorie (simulation)
    final completionByCategory = [
      {'label': 'Arabe', 'percentage': 0.68, 'color': null},
      {'label': 'Coran', 'percentage': 0.72, 'color': null},
      {'label': 'Culture', 'percentage': 0.53, 'color': null},
    ];

    // Retourner les statistiques
    return {
      'totalCourses': courses.length,
      'totalLessons': totalLessons,
      'avgLessonsPerCourse': avgLessonsPerCourse,
      'coursesByCategory': coursesByCategory,
      'coursesByLevel': coursesByLevel,
      'completionRate': completionRate,
      'averageTime': averageTime,
      'beginnerCourses': beginnerCourses,
      'advancedCourses': advancedCourses,
      'popularCourses': popularCourses,
      'completionByCategory': completionByCategory,
    };
  }
}