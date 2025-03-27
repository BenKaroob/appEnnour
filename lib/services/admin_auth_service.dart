import 'dart:async';
import 'dart:convert';
import '../models/index.dart';
import 'mock_admin_data_service.dart';
import 'activity_log_service.dart';

// Service d'authentification spécifique au backoffice
class AdminAuthService {
  Admin? _currentAdmin;
  final StreamController<Admin?> _adminStreamController = StreamController<Admin?>.broadcast();
  final MockAdminDataService _mockAdminDataService = MockAdminDataService();
  final ActivityLogService _activityLogService = ActivityLogService();

  // Singleton pattern
  static final AdminAuthService _instance = AdminAuthService._internal();
  factory AdminAuthService() => _instance;
  AdminAuthService._internal();

  // Getters
  Stream<Admin?> get adminStream => _adminStreamController.stream;
  Admin? get currentAdmin => _currentAdmin;
  bool get isLoggedIn => _currentAdmin != null;

  // Méthode de connexion
  Future<Admin?> login(String email, String password) async {
    // Simuler un délai d'authentification
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Hacher le mot de passe fourni (utiliser la même méthode que dans MockAdminDataService)
      final hashedPassword = 'hashed_$password';

      // Rechercher l'administrateur correspondant
      final admin = _mockAdminDataService.findAdminByEmail(email);

      if (admin != null && admin.passwordHash == hashedPassword) {
        // Mettre à jour la date de dernière connexion
        final updatedAdmin = admin.copyWith(
          lastLogin: DateTime.now(),
        );

        // Sauvegarder la mise à jour
        await _mockAdminDataService.updateAdmin(updatedAdmin);

        // Mettre à jour l'administrateur courant
        _currentAdmin = updatedAdmin;
        _adminStreamController.add(_currentAdmin);

        // Enregistrer l'activité de connexion
        await _activityLogService.logActivity(
          adminId: updatedAdmin.id,
          adminName: updatedAdmin.name,
          action: 'login',
          targetType: 'system',
          description: 'Connexion au backoffice',
        );

        return _currentAdmin;
      }

      return null;
    } catch (e) {
      print('Erreur de connexion: $e');
      return null;
    }
  }

  // Méthode de déconnexion
  Future<void> logout() async {
    if (_currentAdmin != null) {
      // Enregistrer l'activité de déconnexion
      await _activityLogService.logActivity(
        adminId: _currentAdmin!.id,
        adminName: _currentAdmin!.name,
        action: 'logout',
        targetType: 'system',
        description: 'Déconnexion du backoffice',
      );

      // Réinitialiser l'état
      await Future.delayed(const Duration(milliseconds: 500));
      _currentAdmin = null;
      _adminStreamController.add(null);
    }
  }

  // Récupère tous les administrateurs
  Future<List<Admin>> getAllAdmins() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockAdminDataService.admins;
  }

  // Récupère un administrateur par ID
  Future<Admin?> getAdminById(String id) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAdminDataService.findAdminById(id);
  }

  // Crée un nouvel administrateur
  Future<Admin?> createAdmin(Admin admin) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Vérifier que l'email n'existe pas déjà
    final existingAdmin = _mockAdminDataService.findAdminByEmail(admin.email);
    if (existingAdmin != null) {
      throw Exception('Un administrateur avec cet email existe déjà');
    }

    return _mockAdminDataService.createAdmin(admin);
  }

  // Met à jour un administrateur
  Future<Admin?> updateAdmin(Admin admin) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Vérifier que l'admin existe
    final existingAdmin = _mockAdminDataService.findAdminById(admin.id);
    if (existingAdmin == null) {
      throw Exception('Administrateur introuvable');
    }

    // Si c'est l'admin courant, mettre à jour également currentAdmin
    if (_currentAdmin?.id == admin.id) {
      _currentAdmin = admin;
      _adminStreamController.add(_currentAdmin);
    }

    return _mockAdminDataService.updateAdmin(admin);
  }

  // Supprime un administrateur
  Future<bool> deleteAdmin(String adminId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Vérifier que l'admin existe
    final existingAdmin = _mockAdminDataService.findAdminById(adminId);
    if (existingAdmin == null) {
      throw Exception('Administrateur introuvable');
    }

    // Empêcher la suppression de l'admin courant
    if (_currentAdmin?.id == adminId) {
      throw Exception('Vous ne pouvez pas supprimer votre propre compte');
    }

    return _mockAdminDataService.deleteAdmin(adminId);
  }

  // Réinitialise le mot de passe d'un administrateur
  Future<bool> resetAdminPassword(String adminId, String newPassword) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Hacher le nouveau mot de passe
    final hashedPassword = 'hashed_$newPassword';

    // Récupérer l'admin
    final admin = _mockAdminDataService.findAdminById(adminId);
    if (admin == null) {
      throw Exception('Administrateur introuvable');
    }

    // Mettre à jour l'admin avec le nouveau mot de passe
    final updatedAdmin = admin.copyWith(
      passwordHash: hashedPassword,
    );

    final result = await _mockAdminDataService.updateAdmin(updatedAdmin);

    // Si c'est l'admin courant, mettre à jour également currentAdmin
    if (_currentAdmin?.id == adminId && result != null) {
      _currentAdmin = updatedAdmin;
      _adminStreamController.add(_currentAdmin);
    }

    return result != null;
  }

  // Vérifie si l'administrateur courant a une permission spécifique
  bool hasPermission(String permission) {
    return _currentAdmin?.hasPermission(permission) ?? false;
  }

  // Dispose pour nettoyer les ressources
  void dispose() {
    _adminStreamController.close();
  }
}