import 'package:flutter/material.dart';
import 'app_constants.dart';

// Utilitaires généraux pour l'application
class AppUtils {
  // Empêcher l'instanciation
  AppUtils._();

  // Formate la durée en minutes en format lisible (1h 30min)
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  // Traduit le niveau du cours
  static String translateLevel(String level) {
    return AppConstants.translateCourseLevel(level);
  }

  // Obtient l'icône correspondant à la catégorie
  static IconData getCategoryIcon(String iconName) {
    return AppConstants.categoryIcons[iconName] ?? Icons.category;
  }

  // Génère une couleur basée sur le texte (pour les avatars par exemple)
  static Color getColorFromText(String text) {
    // Calculer une valeur de hachage simple
    int hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    // Convertir le hachage en une couleur HSL
    final double hue = (hash % 360).abs().toDouble();

    // Créer une couleur HSL
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.4).toColor();
  }

  // Raccourcit un texte long avec des points de suspension
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }

    return '${text.substring(0, maxLength)}...';
  }

  // Affiche un message snackbar
  static void showSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
        Color? backgroundColor,
        SnackBarAction? action,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  // Affiche une boîte de dialogue de confirmation
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirmer',
        String cancelText = 'Annuler',
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // Formate le score en pourcentage
  static String formatScore(int score) {
    return '$score%';
  }

  // Obtient la couleur correspondant au score
  static Color getScoreColor(int score) {
    if (score >= 90) {
      return Colors.green;
    } else if (score >= 70) {
      return Colors.lightGreen;
    } else if (score >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Vérifie si une adresse email est valide
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  // Vérifie si un mot de passe est valide (min. 6 caractères)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}