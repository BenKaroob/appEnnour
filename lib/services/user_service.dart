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

  // Récupérer tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockDataService.users;
  }

  // Récupérer un utilisateur par son ID
  Future<User> getUserById(String userId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    final user = _mockDataService.findUserById(userId);
    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }
    return user;
  }

  // Mettre à jour le statut d'un utilisateur (actif/inactif)
  Future<User> updateUserStatus(String userId, bool isActive) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Trouver l'index de l'utilisateur
    final index = _mockDataService.users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('Utilisateur non trouvé');
    }

    // Mettre à jour le statut de l'utilisateur
    final updatedUser = _mockDataService.users[index].copyWith(isActive: isActive);
    _mockDataService.users[index] = updatedUser;

    // Si c'est l'utilisateur actuel, mettre à jour également dans authService
    final currentUser = _authService.currentUser;
    if (currentUser != null && currentUser.id == userId) {
      _authService.updateCurrentUser(updatedUser);
    }

    return updatedUser;
  }

  // Créer un nouvel utilisateur
  Future<User> createUser(User user, String password) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 1000));

    // Vérifier si l'email existe déjà
    final existingUser = _mockDataService.findUserByEmail(user.email);
    if (existingUser != null) {
      throw Exception('Un utilisateur avec cet email existe déjà');
    }

    // Générer un ID si nécessaire
    final newUser = user.id.isEmpty
        ? user.copyWith(id: 'user-${DateTime.now().millisecondsSinceEpoch}')
        : user;

    // Ajouter l'utilisateur aux données mockées
    _mockDataService.users.add(newUser);

    // Dans une vraie application, le mot de passe serait haché et stocké de manière sécurisée
    // TODO: Implémenter le hachage de mot de passe

    return newUser;
  }

  // Mettre à jour un utilisateur existant
  Future<User> updateUser(User user) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Trouver l'index de l'utilisateur
    final index = _mockDataService.users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      throw Exception('Utilisateur non trouvé');
    }

    // Mettre à jour l'utilisateur
    _mockDataService.users[index] = user;

    // Si c'est l'utilisateur actuel, mettre à jour également dans authService
    final currentUser = _authService.currentUser;
    if (currentUser != null && currentUser.id == user.id) {
      _authService.updateCurrentUser(user);
    }

    return user;
  }

  // Mettre à jour le mot de passe d'un utilisateur
  Future<bool> updateUserPassword(String userId, String newPassword) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 700));

    // Trouver l'utilisateur
    final index = _mockDataService.users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('Utilisateur non trouvé');
    }

    // Dans une vraie application, le mot de passe serait haché et stocké de manière sécurisée
    // TODO: Implémenter le hachage de mot de passe

    return true;
  }

  // Supprimer un utilisateur
  Future<bool> deleteUser(String userId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Trouver l'index de l'utilisateur
    final index = _mockDataService.users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      return false;
    }

    // Supprimer l'utilisateur
    _mockDataService.users.removeAt(index);

    return true;
  }

  // Réinitialiser le mot de passe d'un utilisateur
  Future<bool> resetUserPassword(String userId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 600));

    // Trouver l'utilisateur
    final index = _mockDataService.users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('Utilisateur non trouvé');
    }

    // Dans une vraie application, un email de réinitialisation serait envoyé
    // ou un mot de passe temporaire serait généré

    return true;
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
      firstName: name ?? user.firstName,
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