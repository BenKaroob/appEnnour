import 'package:flutter/material.dart';

// Constantes utilisées dans toute l'application
class AppConstants {
  // Empêcher l'instanciation
  AppConstants._();

  // Nom de l'application
  static const String appName = 'ENNOUR';

  // Slogan de l'application
  static const String appSlogan = 'Illumine ton savoir';

  // Texte de la bismillah
  static const String bismillah = 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';

  // Messages pour les quiz
  static const Map<String, String> quizResultMessages = {
    'excellent': 'Mashallah, excellent travail !',
    'good': 'Mashallah, tu progresses bien !',
    'average': 'Alhamdulillah, continue tes efforts !',
    'poor': 'Garde courage, révise et réessaie !',
  };

  // Niveaux de cours
  static const Map<String, String> courseLevels = {
    'beginner': 'Débutant',
    'intermediate': 'Intermédiaire',
    'advanced': 'Avancé',
  };

  // Durée pour les animations
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Taille des éléments UI
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Message d'erreur par défaut
  static const String defaultErrorMessage = 'Une erreur est survenue. Veuillez réessayer.';

  // Placeholder pour les images
  static const String placeholderImagePath = 'assets/images/placeholder.jpg';

  // Icônes pour les différentes catégories
  static const Map<String, IconData> categoryIcons = {
    'book': Icons.book,
    'auto_stories': Icons.auto_stories,
    'school': Icons.school,
  };

  // Fonction pour déterminer le message de résultat du quiz en fonction du score
  static String getQuizResultMessage(int score) {
    if (score >= 90) {
      return quizResultMessages['excellent']!;
    } else if (score >= 70) {
      return quizResultMessages['good']!;
    } else if (score >= 50) {
      return quizResultMessages['average']!;
    } else {
      return quizResultMessages['poor']!;
    }
  }

  // Fonction pour traduire le niveau du cours
  static String translateCourseLevel(String level) {
    return courseLevels[level] ?? 'Inconnu';
  }
}