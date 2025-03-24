import 'dart:async';
import '../models/index.dart';
import 'mock_data_service.dart';
import 'auth_service.dart';

// Service pour gérer les informations de l'utilisateur
class UserService {
  final MockDataService _mockDataService = MockDataService();
  final AuthService _authService = AuthService();

  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Récupère l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    return _authService.currentUser;
  }

  // Récupère la progression globale de l'utilisateur
  Future<double> getUserOverallProgress() async {
    final user = _authService.currentUser;
    if (user == null) {
      return 0.0;
    }

    return user.overallProgress;
  }

  // Récupère la liste des cours complétés par l'utilisateur
  Future<List<Course>> getCompletedCourses() async {
    final user = _authService.currentUser;
    if (user == null) {
      return [];
    }

    final completedCourses = <Course>[];
    for (final courseId in user.completedCourseIds) {
      final course = _mockDataService.findCourseById(courseId);
      if (course != null) {
        completedCourses.add(course);
      }
    }

    return completedCourses;
  }

  // Met à jour le profil utilisateur
  Future<User?> updateUserProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      return null;
    }

    // Simuler un délai de mise à jour
    await Future.delayed(const Duration(milliseconds: 800));

    // Créer un utilisateur mis à jour
    final updatedUser = user.copyWith(
      name: name ?? user.name,
      profileImageUrl: profileImageUrl ?? user.profileImageUrl,
    );

    // TODO: Dans une vraie application, cette mise à jour serait envoyée au backend

    // Retourner l'utilisateur mis à jour
    return updatedUser;
  }

  // Vérifie si un cours est complété par l'utilisateur actuel
  Future<bool> hasCompletedCourse(String courseId) async {
    final user = _authService.currentUser;
    if (user == null) {
      return false;
    }

    return user.completedCourseIds.contains(courseId);
  }

  // Marque un cours comme complété pour l'utilisateur actuel
  Future<bool> markCourseAsCompleted(String courseId) async {
    final user = _authService.currentUser;
    if (user == null) {
      return false;
    }

    final userIndex = _mockDataService.users.indexWhere((u) => u.id == user.id);
    if (userIndex == -1) {
      return false;
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Mettre à jour la liste des cours complétés
    final completedCourses = List<String>.from(user.completedCourseIds);
    if (!completedCourses.contains(courseId)) {
      completedCourses.add(courseId);
      // TODO: Dans une vraie application, cette mise à jour serait envoyée au backend
    }

    return true;
  }

// TODO: Implémenter les appels API réels lorsque le backend sera prêt
// Future<User?> fetchUserFromApi(String userId) async {
//   // Implémentation future avec http package
//   return null;
// }
}