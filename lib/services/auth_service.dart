import 'dart:async';
import '../models/index.dart';
import 'mock_data_service.dart';

// Service d'authentification mockée pour le prototype
class AuthService {
  User? _currentUser;
  final StreamController<User?> _userStreamController = StreamController<User?>.broadcast();

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
        final mockUser = MockDataService().findUserByEmail(email);

        // Si trouvé, mettre à jour l'utilisateur courant
        if (mockUser != null) {
          _currentUser = mockUser;
          _userStreamController.add(_currentUser);
          return _currentUser;
        }

        // Si non trouvé mais email valide, créer un utilisateur fictif
        _currentUser = User(
          id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first,
          email: email,
          role: 'student',
        );
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