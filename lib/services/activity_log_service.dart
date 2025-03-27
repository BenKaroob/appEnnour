import 'dart:async';
import '../models/index.dart';

// Service de gestion des journaux d'activité
class ActivityLogService {
  // Liste des logs d'activité mockés
  final List<ActivityLog> _activityLogs = [];

  // Singleton pattern
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal() {
    // Initialiser avec quelques logs d'exemple
    _generateSampleLogs();
  }

  // Génère des logs d'exemple pour le développement
  void _generateSampleLogs() {
    // Administrateur super_admin
    final adminId1 = 'admin-1';
    final adminName1 = 'Super Admin';

    // Administrateur content_manager
    final adminId2 = 'admin-2';
    final adminName2 = 'Gestionnaire de Contenu';

    // Quelques dates pour les logs
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final weekAgo = now.subtract(const Duration(days: 7));

    // Logs pour super_admin
    _activityLogs.addAll([
      ActivityLog(
        id: 'log-1',
        adminId: adminId1,
        adminName: adminName1,
        action: 'login',
        targetType: 'system',
        description: 'Connexion au backoffice',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      ActivityLog(
        id: 'log-2',
        adminId: adminId1,
        adminName: adminName1,
        action: 'create',
        targetType: 'course',
        targetId: 'course-123',
        description: 'Création du cours "Introduction à l\'arabe"',
        timestamp: yesterday,
      ),
      ActivityLog(
        id: 'log-3',
        adminId: adminId1,
        adminName: adminName1,
        action: 'update',
        targetType: 'user',
        targetId: 'user-456',
        description: 'Mise à jour de l\'utilisateur "Mohammed Ali"',
        timestamp: twoDaysAgo,
      ),
      ActivityLog(
        id: 'log-4',
        adminId: adminId1,
        adminName: adminName1,
        action: 'delete',
        targetType: 'category',
        targetId: 'category-789',
        description: 'Suppression de la catégorie "Grammaire avancée"',
        timestamp: weekAgo,
      ),
    ]);

    // Logs pour content_manager
    _activityLogs.addAll([
      ActivityLog(
        id: 'log-5',
        adminId: adminId2,
        adminName: adminName2,
        action: 'login',
        targetType: 'system',
        description: 'Connexion au backoffice',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      ActivityLog(
        id: 'log-6',
        adminId: adminId2,
        adminName: adminName2,
        action: 'create',
        targetType: 'lesson',
        targetId: 'lesson-123',
        description: 'Création de la leçon "Les lettres arabes"',
        timestamp: yesterday.add(const Duration(hours: 3)),
      ),
      ActivityLog(
        id: 'log-7',
        adminId: adminId2,
        adminName: adminName2,
        action: 'update',
        targetType: 'quiz',
        targetId: 'quiz-456',
        description: 'Mise à jour du quiz "Test de connaissance"',
        details: {
          'questions_count': 10,
          'difficulty': 'Intermédiaire',
        },
        timestamp: twoDaysAgo.add(const Duration(hours: 5)),
      ),
      ActivityLog(
        id: 'log-8',
        adminId: adminId2,
        adminName: adminName2,
        action: 'logout',
        targetType: 'system',
        description: 'Déconnexion du backoffice',
        timestamp: yesterday.subtract(const Duration(hours: 1)),
      ),
    ]);

    // Trier les logs par date décroissante
    _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Enregistre une nouvelle activité
  Future<ActivityLog> logActivity({
    required String adminId,
    required String adminName,
    required String action,
    required String targetType,
    String? targetId,
    required String description,
    Map<String, dynamic>? details,
  }) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));

    final activityLog = ActivityLog(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      adminId: adminId,
      adminName: adminName,
      action: action,
      targetType: targetType,
      targetId: targetId,
      description: description,
      details: details,
      timestamp: DateTime.now(),
    );

    // Ajouter au début de la liste pour avoir les plus récents en premier
    _activityLogs.insert(0, activityLog);

    return activityLog;
  }

  // Récupère tous les logs d'activité
  Future<List<ActivityLog>> getAllActivityLogs() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_activityLogs);
  }

  // Récupère les logs d'activité d'un administrateur
  // Ajout du paramètre limit pour compatibilité avec AdminService
  Future<List<ActivityLog>> getAdminActivityLogs(String adminId, {int limit = 0}) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    final logs = _activityLogs.where((log) => log.adminId == adminId).toList();

    // Appliquer la limite si elle est spécifiée (supérieure à 0)
    if (limit > 0 && logs.length > limit) {
      return logs.take(limit).toList();
    }

    return logs;
  }

  // Récupère les logs d'activité pour une entité spécifique
  Future<List<ActivityLog>> getEntityActivityLogs(String targetType, String targetId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _activityLogs
        .where((log) => log.targetType == targetType && log.targetId == targetId)
        .toList();
  }

  // Récupère les logs d'activité récents (les 20 derniers par défaut)
  Future<List<ActivityLog>> getRecentActivityLogs({int limit = 20}) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    return _activityLogs.take(limit).toList();
  }

  // Récupère les logs d'activité pour une période donnée
  Future<List<ActivityLog>> getActivityLogsByDateRange(DateTime start, DateTime end) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 600));
    return _activityLogs
        .where((log) => log.timestamp.isAfter(start) && log.timestamp.isBefore(end))
        .toList();
  }

  // Récupère les logs d'activité pour un type d'action spécifique
  Future<List<ActivityLog>> getActivityLogsByAction(String action) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 400));
    return _activityLogs.where((log) => log.action == action).toList();
  }

  // Recherche dans les logs d'activité
  Future<List<ActivityLog>> searchActivityLogs(String query) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 700));

    final lowerQuery = query.toLowerCase();
    return _activityLogs.where((log) {
      return log.description.toLowerCase().contains(lowerQuery) ||
          log.adminName.toLowerCase().contains(lowerQuery) ||
          log.targetType.toLowerCase().contains(lowerQuery) ||
          (log.targetId != null && log.targetId!.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Efface tous les logs d'activité (principalement pour les tests)
  Future<void> clearAllLogs() async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));
    _activityLogs.clear();
  }
}