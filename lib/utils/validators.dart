class Validators {
  /// Vérifie si une valeur n'est pas vide
  static String? required(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'Ce champ est requis';
    }
    return null;
  }

  /// Vérifie si une valeur est une adresse email valide
  static String? email(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return message ?? 'Email invalide';
    }
    return null;
  }

  /// Vérifie si une valeur est un numéro de téléphone valide
  static String? phone(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Le téléphone est optionnel
    }

    // Regex simple pour numéros internationaux (peut être ajusté selon les besoins)
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return message ?? 'Numéro de téléphone invalide';
    }
    return null;
  }

  /// Vérifie si un mot de passe respecte les critères de sécurité
  static String? password(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    // Critères de sécurité supplémentaires (optionnels)
    // Décommentez pour ajouter des validations plus strictes
    /*
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecialChar) {
      return 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial';
    }
    */

    return null;
  }

  /// Vérifie si deux valeurs sont identiques (pour la confirmation de mot de passe)
  static String? confirmPassword(String? value, String? password, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }

    if (value != password) {
      return message ?? 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  /// Vérifie si une valeur est un nombre
  static String? number(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Le nombre est optionnel
    }

    if (double.tryParse(value) == null) {
      return message ?? 'Veuillez entrer un nombre valide';
    }
    return null;
  }

  /// Vérifie si une valeur est dans une plage numérique
  static String? numberRange(String? value, double min, double max, [String? message]) {
    final numberError = number(value);
    if (numberError != null) {
      return numberError;
    }

    if (value == null || value.trim().isEmpty) {
      return null; // La valeur est optionnelle
    }

    final numValue = double.parse(value);
    if (numValue < min || numValue > max) {
      return message ?? 'Veuillez entrer un nombre entre $min et $max';
    }
    return null;
  }

  /// Vérifie si une valeur a une longueur minimale
  static String? minLength(String? value, int minLength, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return null; // La valeur est optionnelle
    }

    if (value.length < minLength) {
      return message ?? 'Doit contenir au moins $minLength caractères';
    }
    return null;
  }

  /// Vérifie si une valeur a une longueur maximale
  static String? maxLength(String? value, int maxLength, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return null; // La valeur est optionnelle
    }

    if (value.length > maxLength) {
      return message ?? 'Ne doit pas dépasser $maxLength caractères';
    }
    return null;
  }

  /// Vérifie si une valeur est une URL valide
  static String? url(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return null; // L'URL est optionnelle
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return message ?? 'URL invalide';
    }
    return null;
  }

  /// Vérifie si une valeur est une date valide
  static String? date(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return null; // La date est optionnelle
    }

    // Format attendu: JJ/MM/AAAA
    final dateRegex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
    if (!dateRegex.hasMatch(value)) {
      return message ?? 'Format de date invalide (JJ/MM/AAAA)';
    }

    final match = dateRegex.firstMatch(value);
    final day = int.parse(match!.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    if (month < 1 || month > 12) {
      return 'Mois invalide';
    }

    // Vérifier le nombre de jours selon le mois
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // Ajustement pour les années bissextiles
    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
      daysInMonth[1] = 29;
    }

    if (day < 1 || day > daysInMonth[month - 1]) {
      return 'Jour invalide pour le mois sélectionné';
    }

    return null;
  }
}