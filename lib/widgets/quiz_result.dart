import 'package:flutter/material.dart';
import '../utils/index.dart';
import 'progress_indicator_widget.dart';

// Widget pour afficher le résultat d'un quiz complété
class QuizResultWidget extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onNextPressed;
  final bool showNextButton;

  const QuizResultWidget({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    this.onRetryPressed,
    this.onNextPressed,
    this.showNextButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resultMessage = AppConstants.getQuizResultMessage(score);
    final resultColor = AppUtils.getScoreColor(score);

    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre du résultat
            Text(
              'Résultat du Quiz',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Indicateur de score circulaire
            CircularProgressWidget(
              progress: score.toDouble(),
              size: 120,
              progressColor: resultColor,
            ),
            const SizedBox(height: 24),

            // Message de résultat
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: resultColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                resultMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Détails du résultat
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    'Questions correctes',
                    '$correctAnswers sur $totalQuestions',
                    AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    'Score total',
                    '$score%',
                    AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton pour réessayer
                if (onRetryPressed != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRetryPressed,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                if (onRetryPressed != null && showNextButton)
                  const SizedBox(width: 16),

                // Bouton pour continuer
                if (showNextButton)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNextPressed,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continuer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Construction d'une ligne de détail
  Widget _buildDetailRow(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}