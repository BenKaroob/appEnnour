import '../models/index.dart';
import 'mock_admin_data_service.dart';
import 'admin_auth_service.dart';
import 'activity_log_service.dart';

// Service pour gérer les administrateurs du backoffice
class AdminService {
  final MockAdminDataService _mockAdminDataService = MockAdminDataService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  final ActivityLogService _activityLogService = ActivityLogService();

  // Singleton pattern
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  // Récupère tous les administrateurs
  Future<List<Admin>> getAllAdmins() async {
    // Vérifier les permissions (seul super_admin peut voir tous les admins)
    final currentAdmin = _adminAuthService.currentAdmin;
    if (currentAdmin == null || currentAdmin.role != 'super_admin') {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAdminDataService.admins;
  }

  // Récupère un administrateur par son ID
  Future<Admin?> getAdminById(String adminId) async {
    // Vérifier les permissions (seul super_admin peut voir d'autres admins)
    final currentAdmin = _adminAuthService.currentAdmin;
    if (currentAdmin == null) {
      throw Exception('Non authentifié');
    }

    // Permettre à un admin de voir ses propres informations
    if (currentAdmin.id != adminId && currentAdmin.role != 'super_admin') {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAdminDataService.findAdminById(adminId);
  }

  // Crée un nouvel administrateur
  Future<Admin?> createAdmin(Admin admin) async {
    // Vérifier les permissions (seul super_admin peut créer d'autres admins)
    final currentAdmin = _adminAuthService.currentAdmin;
    if (currentAdmin == null || currentAdmin.role != 'super_admin') {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Créer l'administrateur
    final newAdmin = await _mockAdminDataService.createAdmin(admin);

    // Enregistrer l'activité
    if (newAdmin != null) {
      await _activityLogService.logActivity(
        adminId: currentAdmin.id,
        adminName: currentAdmin.name,
        action: 'create',
        targetType: 'admin',
        targetId: newAdmin.id,
        description: 'Création de l\'administrateur "${newAdmin.name}"',
        details: {
          'email': newAdmin.email,
          'role': newAdmin.role,
        },
      );
    }

    return newAdmin;
  }

  // Met à jour un administrateur existant
  Future<Admin?> updateAdmin(Admin admin) async {
    // Vérifier les permissions
    final currentAdmin = _adminAuthService.currentAdmin;
    if (currentAdmin == null) {
      throw Exception('Non authentifié');
    }

    // Permettre à un admin de mettre à jour ses propres informations
    // ou super_admin peut modifier n'importe quel admin
    if (currentAdmin.id != admin.id && currentAdmin.role != 'super_admin') {
      throw Exception('Accès non autorisé');
    }

    // Empêcher un admin de modifier son propre rôle
    if (currentAdmin.id == admin.id && currentAdmin.role != admin.role) {
      throw Exception('Vous ne pouvez pas modifier votre propre rôle');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Mettre à jour l'administrateur
    final updatedAdmin = await _mockAdminDataService.updateAdmin(admin);

    // Enregistrer l'activité
    if (updatedAdmin != null) {
      await _activityLogService.logActivity(
        adminId: currentAdmin.id,
        adminName: currentAdmin.name,
        action: 'update',
        targetType: 'admin',
        targetId: updatedAdmin.id,
        description: 'Mise à jour de l\'administrateur "${updatedAdmin.name}"',
      );
    }

    return updatedAdmin;
  }

  // Supprime un administrateur
  Future<bool> deleteAdmin(String adminId) async {
    // Vérifier les permissions (seul super_admin peut supprimer des admins)
    final currentAdmin = _adminAuthService.currentAdmin;
    if (currentAdmin == null || currentAdmin.role != 'super_admin') {
      throw Exception('Accès non autorisé');
    }

    // Empêcher un admin de se supprimer lui-même
    if (currentAdmin.id == adminId) {
      throw Exception('Vous ne pouvez pas supprimer votre propre compte');
    }

    // Vérifier si l'administrateur existe
    final admin = _mockAdminDataService.findAdminById(adminId);
    if (admin == null) {
      return false;
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Supprimer l'administrateur
    final success = await _mockAdminDataService.deleteAdmin(adminId);

    // Enregistrer l'activité
    if (success) {
      await _activityLogService.logActivity(
        adminId: currentAdmin.id,
        adminName: currentAdmin.name,
        action: 'delete',
        targetType: 'admin',
        targetId: adminId,
        description: 'Suppression de l\'administrateur "${admin.name}"',
      );
    }

    return success;
  }

  // Modifie le mot de passe d'un administrateur
  Future<bool> changePassword(String adminId, String currentPassword, String newPassword) async {
    // Vérifier les permissions
    final currentAdmin = _adminAuthService.currentAdmin;
    if (currentAdmin == null) {
      throw Exception('Non authentifié');
    }

    // Seul l'admin lui-même ou un super_admin peut changer le mot de passe
    if (currentAdmin.id != adminId && currentAdmin.role != 'super_admin') {
      throw Exception('Accès non autorisé');
    }

    // Vérifier si l'administrateur existe
    final admin = _mockAdminDataService.findAdminById(adminId);
    if (admin == null) {
      return false;
    }

    // Vérifier l'ancien mot de passe (sauf pour super_admin qui peut le faire directement)
    if (currentAdmin.id == adminId && admin.passwordHash != _hashPassword(currentPassword)) {
      throw Exception('Mot de passe actuel incorrect');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Dans un vrai système, mettre à jour le mot de passe
    // Pour le prototype, on simule simplement un succès

    // Enregistrer l'activité
    await _activityLogService.logActivity(
      adminId: currentAdmin.id,
      adminName: currentAdmin.name,
      action: 'update',
      targetType: 'admin',
      targetId: adminId,
      description: 'Modification du mot de passe pour l\'administrateur "${admin.name}"',
    );

    return true;
  }

  // Obtient les activités récentes d'un administrateur
  Future<List<ActivityLog>> getAdminActivities(String adminId, {int limit = 20}) async {
    // Vérifier les permissions
    final currentAdmin = _adminAuthService.currentAdmin;
    if (currentAdmin == null) {
      throw Exception('Non authentifié');
    }

    // Seul l'admin lui-même ou un super_admin peut voir les activités
    if (currentAdmin.id != adminId && currentAdmin.role != 'super_admin') {
      throw Exception('Accès non autorisé');
    }

    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 400));

    // Récupérer les activités
    return _activityLogService.getAdminActivityLogs(adminId, limit: limit);
  }

  // Méthode utilitaire pour hacher un mot de passe
  String _hashPassword(String password) {
    // NOTE: Dans une vraie application, utilisez un algorithme de hachage sécurisé avec sel
    // Ceci est une simulation simplifiée pour le prototype
    return 'hashed_$password';
  }
}