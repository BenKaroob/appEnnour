// Modèle User qui représente un utilisateur de l'application
class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'student' ou 'parent'
  final String profileImageUrl;
  final List<String> completedCourseIds;
  final Map<String, int> quizScores; // courseId: score

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl = '',
    this.completedCourseIds = const [],
    this.quizScores = const {},
  });

  // Calcule le pourcentage global de progression
  double get overallProgress {
    if (quizScores.isEmpty) return 0.0;

    final totalScore = quizScores.values.reduce((sum, score) => sum + score);
    final maxPossibleScore = quizScores.length * 100;

    return (totalScore / maxPossibleScore) * 100;
  }

  // Crée une copie du User avec des modifications spécifiques
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? profileImageUrl,
    List<String>? completedCourseIds,
    Map<String, int>? quizScores,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      completedCourseIds: completedCourseIds ?? this.completedCourseIds,
      quizScores: quizScores ?? this.quizScores,
    );
  }

  // Création d'un User à partir d'un map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profileImageUrl: json['profileImageUrl'] ?? '',
      completedCourseIds: List<String>.from(json['completedCourseIds'] ?? []),
      quizScores: Map<String, int>.from(json['quizScores'] ?? {}),
    );
  }

  // Conversion du User en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'completedCourseIds': completedCourseIds,
      'quizScores': quizScores,
    };
  }
}