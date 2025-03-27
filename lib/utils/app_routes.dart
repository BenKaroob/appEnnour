import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/course_list_page.dart';
import '../pages/course_detail_page.dart';
import '../pages/quiz_page.dart';
import '../pages/profile_page.dart';
import '../pages/splash_screen.dart';
import '../pages/admin/admin_login_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/admin_users_page.dart';
import '../pages/admin/admin_user_form_page.dart';
import '../pages/admin/admin_user_detail_page.dart';

// Gestionnaire des routes de l'application
class AppRoutes {
  // Noms des routes pour la navigation
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String courseList = '/course-list';
  static const String courseDetail = '/course-detail';
  static const String quiz = '/quiz';
  static const String profile = '/profile';

  // Routes pour l'administration
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminUserForm = '/admin/users/form';
  static const String adminUserDetail = '/admin/users/detail';

  // Route initiale
  static const String initialRoute = splash;

  // Générateur de routes pour MaterialApp
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // Routes utilisateur
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case courseList:
        final args = settings.arguments as Map<String, dynamic>?;
        final categoryId = args?['categoryId'] as String? ?? '';
        final categoryName = args?['categoryName'] as String? ?? 'Cours';

        return MaterialPageRoute(
          builder: (_) => CourseListPage(
            categoryId: categoryId,
            categoryName: categoryName,
          ),
        );

      case courseDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?['courseId'] as String? ?? '';

        return MaterialPageRoute(
          builder: (_) => CourseDetailPage(courseId: courseId),
        );

      case quiz:
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?['courseId'] as String? ?? '';
        final quizId = args?['quizId'] as String? ?? '';

        return MaterialPageRoute(
          builder: (_) => QuizPage(
            courseId: courseId,
            quizId: quizId,
          ),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

    // Routes d'administration
      case adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginPage());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      case adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersPage());

      case adminUserForm:
        final args = settings.arguments as Map<String, dynamic>?;
        final user = args?['user'];

        return MaterialPageRoute(
          builder: (_) => AdminUserFormPage(user: user),
        );

      case adminUserDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String? ?? '';

        return MaterialPageRoute(
          builder: (_) => AdminUserDetailPage(userId: userId),
        );

      default:
      // Route par défaut en cas d'erreur
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non définie: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Méthode d'aide pour la navigation vers la page de cours
  static void navigateToCourseList(BuildContext context, String categoryId, String categoryName) {
    Navigator.pushNamed(
      context,
      courseList,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  // Méthode d'aide pour la navigation vers le détail d'un cours
  static void navigateToCourseDetail(BuildContext context, String courseId) {
    Navigator.pushNamed(
      context,
      courseDetail,
      arguments: {
        'courseId': courseId,
      },
    );
  }

  // Méthode d'aide pour la navigation vers un quiz
  static void navigateToQuiz(BuildContext context, String courseId, String quizId) {
    Navigator.pushNamed(
      context,
      quiz,
      arguments: {
        'courseId': courseId,
        'quizId': quizId,
      },
    );
  }

  // Méthode d'aide pour la navigation vers l'administration
  static void navigateToAdminLogin(BuildContext context) {
    Navigator.pushNamed(context, adminLogin);
  }

  // Méthode d'aide pour la navigation vers le détail d'un utilisateur
  static void navigateToAdminUserDetail(BuildContext context, String userId) {
    Navigator.pushNamed(
      context,
      adminUserDetail,
      arguments: {
        'userId': userId,
      },
    );
  }

  // Méthode d'aide pour la navigation vers le formulaire d'utilisateur
  static void navigateToAdminUserForm(BuildContext context, {dynamic user}) {
    Navigator.pushNamed(
      context,
      adminUserForm,
      arguments: {
        'user': user,
      },
    );
  }
}