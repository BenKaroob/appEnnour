import 'dart:async';
import '../models/index.dart';
import 'mock_data_service.dart';

// Service d'authentification mockée pour le prototype
class AuthService {
  User? _currentUser;
  final StreamController<User?> _userStreamController = StreamController<User?>.broadcast();
  final MockDataService _mockDataService = MockDataService();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Getters
  Stream<User?> get userStream => _userStreamController.stream;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Méthode de connexion mockée
  Future<User?> login(String email, String password) async {
    // Simuler un délai d'authentification
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Pour le prototype, on accepte toute connexion avec email non-vide
      if (email.isNotEmpty) {
        // Chercher l'utilisateur dans les données mockées
        final mockUser = _mockDataService.findUserByEmail(email);

        // Si trouvé, mettre à jour l'utilisateur courant
        if (mockUser != null) {
          // Mettre à jour la date de dernière connexion
          final updatedUser = mockUser.copyWith(
            lastLoginDate: DateTime.now(),
          );

          _currentUser = updatedUser;
          _userStreamController.add(_currentUser);
          return _currentUser;
        }

        // Si non trouvé mais email valide, créer un utilisateur fictif
        final nameParts = email.split('@').first.split('.');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : 'Utilisateur';
        final lastName = nameParts.length > 1 ? nameParts[1] : '';

        _currentUser = User(
          id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
          firstName: firstName,
          lastName: lastName,
          email: email,
          username: email,  // Utiliser l'email comme nom d'utilisateur par défaut
          role: 'student',
          isActive: true,
          creationDate: DateTime.now(),
          lastLoginDate: DateTime.now(),
        );

        // Ajouter l'utilisateur aux données mockées pour les futures connexions
        _mockDataService.users.add(_currentUser!);

        _userStreamController.add(_currentUser);
        return _currentUser;
      }

      // Email vide, échec de connexion
      return null;
    } catch (e) {
      print('Erreur de connexion: $e');
      return null;
    }
  }

  // Mise à jour de l'utilisateur courant
  Future<User?> updateCurrentUser(User user) async {
    // Vérifier que l'utilisateur est connecté
    if (_currentUser == null) {
      print('Aucun utilisateur connecté, impossible de mettre à jour');
      return null;
    }

    // Vérifier que l'ID correspond à l'utilisateur courant
    if (_currentUser!.id != user.id) {
      print('ID d\'utilisateur ne correspond pas à l\'utilisateur connecté');
      return _currentUser;
    }

    // Mettre à jour l'utilisateur dans la base de données mockée
    final userIndex = _mockDataService.users.indexWhere((u) => u.id == user.id);
    if (userIndex >= 0) {
      _mockDataService.users[userIndex] = user;
    }

    // Mettre à jour l'utilisateur courant
    _currentUser = user;
    _userStreamController.add(_currentUser);

    return _currentUser;
  }

  // Méthode de déconnexion
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _userStreamController.add(null);
  }

  // Dispose pour nettoyer les ressources
  void dispose() {
    _userStreamController.close();
  }
}