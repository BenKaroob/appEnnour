// Modèle Lesson qui représente une leçon dans un cours
class Lesson {
  final String id;
  final String title;
  final String content;
  final int orderIndex; // Pour ordonner les leçons
  final int durationMinutes;
  final String? videoUrl;
  final String? imageUrl;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.orderIndex,
    this.durationMinutes = 0,
    this.videoUrl,
    this.imageUrl,
  });

  // Crée une copie de Lesson avec des modifications spécifiques
  Lesson copyWith({
    String? id,
    String? title,
    String? content,
    int? orderIndex,
    int? durationMinutes,
    String? videoUrl,
    String? imageUrl,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      orderIndex: orderIndex ?? this.orderIndex,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Création d'une Lesson à partir d'un map (JSON)
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      orderIndex: json['orderIndex'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 0,
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
    );
  }

  // Conversion de la Lesson en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'orderIndex': orderIndex,
      'durationMinutes': durationMinutes,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
    };
  }
}