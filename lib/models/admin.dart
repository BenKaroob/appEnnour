// Modèle Admin qui représente un administrateur du backoffice
class Admin {
  final String id;
  final String name;
  final String email;
  final String role; // 'super_admin', 'course_admin', 'content_manager'
  final String passwordHash; // Mot de passe haché (dans un vrai système, ce serait crypté)
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? lastLogin;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.passwordHash,
    this.permissions = const [],
    required this.createdAt,
    this.lastLogin,
  });

  // Crée une copie de l'Admin avec des modifications spécifiques
  Admin copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? passwordHash,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return Admin(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Création d'un Admin à partir d'un map (JSON)
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      passwordHash: json['passwordHash'],
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  // Conversion de l'Admin en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'passwordHash': passwordHash,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Vérifie si l'administrateur a une permission spécifique
  bool hasPermission(String permission) {
    // Super admin a toutes les permissions
    if (role == 'super_admin') return true;

    return permissions.contains(permission);
  }

  // Traduit le rôle pour l'affichage
  String get displayRole {
    switch (role) {
      case 'super_admin':
        return 'Super Administrateur';
      case 'course_admin':
        return 'Administrateur de cours';
      case 'content_manager':
        return 'Gestionnaire de contenu';
      default:
        return 'Utilisateur';
    }
  }
}