// Modèle User enrichi pour l'application ENNOUR
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String username;
  final String role; // 'student' ou 'parent'
  final bool isActive;

  // Informations personnelles optionnelles
  final String? address;
  final String? nationality;
  final String? emergencyContact;
  final String? gender;
  final DateTime? birthDate;

  // Informations du système
  final DateTime? creationDate;
  final DateTime? lastLoginDate;
  final String profileImageUrl;

  // Informations de progression
  final List<String> completedCourseIds;
  final List<String>? completedCourses;
  final List<String>? inProgressCourses;
  final Map<String, int> quizScores; // courseId: score

  // Relations familiales (pour les parents)
  final List<String>? childrenIds;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.username,
    required this.role,
    this.isActive = true,
    this.address,
    this.nationality,
    this.emergencyContact,
    this.gender,
    this.birthDate,
    this.creationDate,
    this.lastLoginDate,
    this.profileImageUrl = '',
    this.completedCourseIds = const [],
    this.completedCourses = const [],
    this.inProgressCourses = const [],
    this.quizScores = const {},
    this.childrenIds = const [],
  });

  // Nom complet (concaténation du prénom et du nom)
  String get name => '$firstName $lastName';

  // Calcule le pourcentage global de progression
  double get overallProgress {
    if (quizScores.isEmpty) return 0.0;

    final totalScore = quizScores.values.reduce((sum, score) => sum + score);
    final maxPossibleScore = quizScores.length * 100;
    return (totalScore / maxPossibleScore) * 100;
  }

  // Vérifie si l'utilisateur est un parent
  bool get isParent => role == 'parent';

  // Vérifie si l'utilisateur est un étudiant
  bool get isStudent => role == 'student';

  // Crée une copie du User avec des modifications spécifiques
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? username,
    String? role,
    bool? isActive,
    String? address,
    String? nationality,
    String? emergencyContact,
    String? gender,
    DateTime? birthDate,
    DateTime? creationDate,
    DateTime? lastLoginDate,
    String? profileImageUrl,
    List<String>? completedCourseIds,
    List<String>? completedCourses,
    List<String>? inProgressCourses,
    Map<String, int>? quizScores,
    List<String>? childrenIds,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      creationDate: creationDate ?? this.creationDate,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      completedCourseIds: completedCourseIds ?? this.completedCourseIds,
      completedCourses: completedCourses ?? this.completedCourses,
      inProgressCourses: inProgressCourses ?? this.inProgressCourses,
      quizScores: quizScores ?? this.quizScores,
      childrenIds: childrenIds ?? this.childrenIds,
    );
  }

  // Création d'un User à partir d'un map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      username: json['username'] ?? json['email'], // Utiliser l'email comme username par défaut
      role: json['role'],
      isActive: json['isActive'] ?? true,
      address: json['address'],
      nationality: json['nationality'],
      emergencyContact: json['emergencyContact'],
      gender: json['gender'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : null,
      lastLoginDate: json['lastLoginDate'] != null ? DateTime.parse(json['lastLoginDate']) : null,
      profileImageUrl: json['profileImageUrl'] ?? '',
      completedCourseIds: List<String>.from(json['completedCourseIds'] ?? []),
      completedCourses: json['completedCourses'] != null ? List<String>.from(json['completedCourses']) : null,
      inProgressCourses: json['inProgressCourses'] != null ? List<String>.from(json['inProgressCourses']) : null,
      quizScores: Map<String, int>.from(json['quizScores'] ?? {}),
      childrenIds: json['childrenIds'] != null ? List<String>.from(json['childrenIds']) : null,
    );
  }

  // Conversion du User en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'username': username,
      'role': role,
      'isActive': isActive,
      'address': address,
      'nationality': nationality,
      'emergencyContact': emergencyContact,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'creationDate': creationDate?.toIso8601String(),
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'completedCourseIds': completedCourseIds,
      'completedCourses': completedCourses,
      'inProgressCourses': inProgressCourses,
      'quizScores': quizScores,
      'childrenIds': childrenIds,
    };
  }
}