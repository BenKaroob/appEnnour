import '../models/index.dart';
import 'mock_data_service.dart';

// Service contenant toutes les données mockées pour le backoffice
class MockAdminDataService {
  // Singleton pattern
  static final MockAdminDataService _instance = MockAdminDataService._internal();
  factory MockAdminDataService() => _instance;
  MockAdminDataService._internal() {
    _initMockData();
  }

  // Collections de données
  final List<Admin> _admins = [];
  final List<ActivityLog> _activityLogs = [];
  final MockDataService _mockDataService = MockDataService();

  // Getters pour accéder aux données
  List<Admin> get admins => List.unmodifiable(_admins);
  List<ActivityLog> get activityLogs => List.unmodifiable(_activityLogs);
  MockDataService get dataService => _mockDataService;

  // Méthode d'initialisation des données mockées
  void _initMockData() {
    // Initialiser les administrateurs
    _initAdmins();

    // Initialiser les logs d'activité
    _initActivityLogs();
  }

  // Initialisation des administrateurs
  void _initAdmins() {
    _admins.addAll([
      Admin(
        id: 'admin-1',
        name: 'Admin Principal',
        email: 'admin@ennour.com',
        role: 'super_admin',
        passwordHash: _hashSHA256('admin123'), // Dans un vrai système, ce serait crypté
        permissions: ['*'],
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Admin(
        id: 'admin-2',
        name: 'Gestionnaire de Contenu',
        email: 'content@ennour.com',
        role: 'content_manager',
        passwordHash: _hashSHA256('content123'),
        permissions: ['read:all', 'create:course', 'update:course', 'create:lesson', 'update:lesson'],
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastLogin: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Admin(
        id: 'admin-3',
        name: 'Gestionnaire des Utilisateurs',
        email: 'users@ennour.com',
        role: 'course_admin',
        passwordHash: _hashSHA256('users123'),
        permissions: ['read:all', 'create:user', 'update:user', 'read:stats'],
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastLogin: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  // Initialisation des logs d'activité
  void _initActivityLogs() {
    final now = DateTime.now();

    _activityLogs.addAll([
      ActivityLog(
        id: 'log-1',
        adminId: 'admin-1',
        adminName: 'Admin Principal',
        action: 'login',
        targetType: 'system',
        description: 'Connexion au backoffice',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ActivityLog(
        id: 'log-2',
        adminId: 'admin-1',
        adminName: 'Admin Principal',
        action: 'create',
        targetType: 'course',
        targetId: 'course-1',
        description: 'Création du cours "L\'alphabet arabe"',
        timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
      ),
      ActivityLog(
        id: 'log-3',
        adminId: 'admin-2',
        adminName: 'Gestionnaire de Contenu',
        action: 'update',
        targetType: 'course',
        targetId: 'course-1',
        description: 'Mise à jour du cours "L\'alphabet arabe"',
        timestamp: now.subtract(const Duration(hours: 12)),
      ),
      ActivityLog(
        id: 'log-4',
        adminId: 'admin-3',
        adminName: 'Gestionnaire des Utilisateurs',
        action: 'create',
        targetType: 'user',
        targetId: 'user-1',
        description: 'Création de l\'utilisateur "Ahmed Benali"',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
    ]);
  }

  // Recherche d'un administrateur par email
  Admin? findAdminByEmail(String email) {
    try {
      return _admins.firstWhere((admin) => admin.email == email);
    } catch (e) {
      return null;
    }
  }

  // Recherche d'un administrateur par ID
  Admin? findAdminById(String id) {
    try {
      return _admins.firstWhere((admin) => admin.id == id);
    } catch (e) {
      return null;
    }
  }

  // Création d'un nouvel administrateur
  Future<Admin?> createAdmin(Admin admin) async {
    // Vérifier si l'email existe déjà
    if (_admins.any((a) => a.email == admin.email)) {
      return null;
    }

    _admins.add(admin);
    return admin;
  }

  // Mise à jour d'un administrateur existant
  Future<Admin?> updateAdmin(Admin updatedAdmin) async {
    final index = _admins.indexWhere((admin) => admin.id == updatedAdmin.id);
    if (index != -1) {
      _admins[index] = updatedAdmin;
      return updatedAdmin;
    }
    return null;
  }

  // Suppression d'un administrateur
  Future<bool> deleteAdmin(String adminId) async {
    final initialLength = _admins.length;
    _admins.removeWhere((admin) => admin.id == adminId);
    return _admins.length < initialLength;
  }

  // Ajout d'un log d'activité
  Future<ActivityLog> addActivityLog(ActivityLog log) async {
    _activityLogs.add(log);
    return log;
  }

  // Obtenir les logs d'activité filtrés
  List<ActivityLog> getActivityLogs({
    String? adminId,
    String? action,
    String? targetType,
    String? targetId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) {
    // Filtrer les logs selon les critères
    return _activityLogs
        .where((log) => adminId == null || log.adminId == adminId)
        .where((log) => action == null || log.action == action)
        .where((log) => targetType == null || log.targetType == targetType)
        .where((log) => targetId == null || log.targetId == targetId)
        .where((log) => startDate == null || log.timestamp.isAfter(startDate))
        .where((log) => endDate == null || log.timestamp.isBefore(endDate))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)) // Tri par date (plus récent d'abord)
      ..take(limit);
  }

  // Fonction utilitaire pour hacher un mot de passe (SHA-256 simulé)
  String _hashSHA256(String input) {
    // NOTE: Dans une vraie application, utilisez un algorithme de hachage sécurisé avec sel
    // Ceci est une simulation simplifiée pour le prototype
    return 'hashed_$input';
  }
}