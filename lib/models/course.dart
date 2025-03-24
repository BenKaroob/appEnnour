// Modèle Course qui représente un cours disponible dans l'application
import 'package:app_ennour/models/quiz.dart';

import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String level; // 'beginner', 'intermediate', 'advanced'
  final String imageUrl;
  final String videoUrl;
  final String pdfUrl;
  final int durationMinutes;
  final List<Lesson> lessons;
  final Quiz quiz;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.level,
    required this.imageUrl,
    required this.videoUrl,
    required this.pdfUrl,
    required this.durationMinutes,
    required this.lessons,
    required this.quiz,
  });

  // Crée une copie du Course avec des modifications spécifiques
  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? level,
    String? imageUrl,
    String? videoUrl,
    String? pdfUrl,
    int? durationMinutes,
    List<Lesson>? lessons,
    Quiz? quiz,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lessons: lessons ?? this.lessons,
      quiz: quiz ?? this.quiz,
    );
  }

  // Création d'un Course à partir d'un map (JSON)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      categoryId: json['categoryId'],
      level: json['level'],
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      lessons: (json['lessons'] as List?)
          ?.map((lessonJson) => Lesson.fromJson(lessonJson))
          .toList() ??
          [],
      quiz: Quiz.fromJson(json['quiz'] ?? {}),
    );
  }

  // Conversion du Course en map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'level': level,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'durationMinutes': durationMinutes,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'quiz': quiz.toJson(),
    };
  }
}