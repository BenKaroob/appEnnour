import 'package:flutter/material.dart';
import '../utils/index.dart';

// Widget pour afficher un indicateur de progression circulaire
class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;
  final Color? backgroundColor;
  final Color? progressColor;
  final double strokeWidth;
  final Widget? child;

  const CircularProgressWidget({
    Key? key,
    required this.progress,
    this.size = 80.0,
    this.backgroundColor,
    this.progressColor,
    this.strokeWidth = 8.0,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[200];
    final pgColor = progressColor ?? AppTheme.primaryColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de fond
          CircularProgressIndicator(
            value: 1.0,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(bgColor!),
            strokeWidth: strokeWidth,
          ),

          // Indicateur de progression
          CircularProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(pgColor),
            strokeWidth: strokeWidth,
          ),

          // Contenu central (texte ou autre widget)
          child ?? Text(
            '${progress.toInt()}%',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: pgColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour afficher un indicateur de progression linéaire
class LinearProgressWidget extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final String? label;
  final bool showPercentage;

  const LinearProgressWidget({
    Key? key,
    required this.progress,
    this.height = 16.0,
    this.backgroundColor,
    this.progressColor,
    this.label,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[200];
    final pgColor = progressColor ?? AppTheme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Étiquette et pourcentage
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${progress.toInt()}%',
                    style: TextStyle(
                      color: pgColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

        // Barre de progression
        Stack(
          children: [
            // Fond
            Container(
              height: height,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            // Progression
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final progressWidth = (progress / 100) * maxWidth;

                return Container(
                  height: height,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    color: pgColor,
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: pgColor.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}