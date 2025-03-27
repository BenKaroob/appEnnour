// Modèle ActivityLog qui représente une action effectuée par un administrateur
class ActivityLog {
  final String id;
  final String adminId;
  final String adminName;
  final String action; // 'create', 'update', 'delete', 'login', 'logout'
  final String targetType; // 'course', 'user', 'category', 'lesson', 'quiz', 'system'
  final String? targetId;
  final String description;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetType,
    this.targetId,
    required this.description,
    this.details,
    required this.timestamp,
  });

  // Crée une copie de l'ActivityLog avec des modifications spécifiques
  ActivityLog copyWith({
    String? id,
    String? adminId,
    String? adminName,
    String? action,
    String? targetType,
    String? targetId,
    String? description,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      action: action ?? this.action,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      description: description ?? this.description,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Création d'un ActivityLog à partir d'un map (JSON)
  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      adminId: json['adminId'],
      adminName: json['adminName'],
      action: json['action'],
      targetType: json['targetType'],
      targetId: json['targetId'],
      description: json['description'],
      details: json['details'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Conversion de l'ActivityLog en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'adminName': adminName,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'description': description,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Obtient une icône représentative pour l'action
  String get actionIcon {
    switch (action) {
      case 'create':
        return '➕';
      case 'update':
        return '✏️';
      case 'delete':
        return '🗑️';
      case 'login':
        return '🔑';
      case 'logout':
        return '🔒';
      default:
        return '📋';
    }
  }

  // Traduit le type de cible pour l'affichage
  String get displayTargetType {
    switch (targetType) {
      case 'course':
        return 'Cours';
      case 'user':
        return 'Utilisateur';
      case 'category':
        return 'Catégorie';
      case 'lesson':
        return 'Leçon';
      case 'quiz':
        return 'Quiz';
      case 'system':
        return 'Système';
      default:
        return targetType;
    }
  }

  // Obtient une couleur représentative pour l'action
  String get actionColor {
    switch (action) {
      case 'create':
        return '#4CAF50'; // Vert
      case 'update':
        return '#2196F3'; // Bleu
      case 'delete':
        return '#F44336'; // Rouge
      case 'login':
        return '#9C27B0'; // Violet
      case 'logout':
        return '#607D8B'; // Bleu-gris
      default:
        return '#757575'; // Gris
    }
  }
}