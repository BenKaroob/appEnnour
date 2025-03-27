import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Widget réutilisable qui affiche un indicateur de chargement.
///
/// Ce widget centre un [CircularProgressIndicator] et peut afficher
/// un message de chargement optionnel en dessous. Il est conçu pour être
/// utilisé partout où une opération asynchrone est en cours.
class LoadingIndicator extends StatelessWidget {
  /// Message à afficher sous l'indicateur de chargement.
  final String? message;

  /// Taille de l'indicateur de chargement.
  final double size;

  /// Couleur de l'indicateur de chargement.
  final Color? color;

  /// Contrôle l'opacité du fond derrière l'indicateur.
  final double backgroundOpacity;

  /// Crée un indicateur de chargement.
  ///
  /// [message] est un texte optionnel affiché sous l'indicateur.
  /// [size] définit la taille de l'indicateur (par défaut 40.0).
  /// [color] définit la couleur de l'indicateur (utilise la couleur primaire du thème par défaut).
  /// [backgroundOpacity] définit l'opacité du fond (0.0 par défaut, donc transparent).
  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 40.0,
    this.color,
    this.backgroundOpacity = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(backgroundOpacity),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Theme.of(context).primaryColor,
                ),
                strokeWidth: 3.0,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16.0),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16.0,
                  color: color ?? Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}