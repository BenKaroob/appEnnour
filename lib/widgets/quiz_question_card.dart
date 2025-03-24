import 'package:flutter/material.dart';
import '../models/index.dart';
import '../utils/index.dart';

// Widget pour afficher une question de quiz avec options de réponse
class QuizQuestionCard extends StatefulWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final Function(int) onOptionSelected;
  final int? selectedOptionIndex;
  final bool showCorrectAnswer;

  const QuizQuestionCard({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onOptionSelected,
    this.selectedOptionIndex,
    this.showCorrectAnswer = false,
  }) : super(key: key);

  @override
  State<QuizQuestionCard> createState() => _QuizQuestionCardState();
}

class _QuizQuestionCardState extends State<QuizQuestionCard> {
  // Détermine la couleur en fonction de la sélection et si la réponse est correcte
  Color _getOptionColor(int optionIndex) {
    // Si on ne montre pas encore les réponses correctes, utiliser un style simple
    if (!widget.showCorrectAnswer) {
      if (widget.selectedOptionIndex == optionIndex) {
        return AppTheme.primaryColor;
      }
      return Colors.white;
    }

    // Coloration en fonction de la correction
    if (optionIndex == widget.question.correctOptionIndex) {
      return Colors.green[100]!; // Bonne réponse
    } else if (widget.selectedOptionIndex == optionIndex) {
      return Colors.red[100]!; // Mauvaise réponse sélectionnée
    }

    return Colors.white; // Option non sélectionnée
  }

  // Détermine la couleur de bordure
  Color _getBorderColor(int optionIndex) {
    // Si on ne montre pas encore les réponses correctes, utiliser un style simple
    if (!widget.showCorrectAnswer) {
      if (widget.selectedOptionIndex == optionIndex) {
        return AppTheme.primaryColor;
      }
      return Colors.grey[300]!;
    }

    // Coloration en fonction de la correction
    if (optionIndex == widget.question.correctOptionIndex) {
      return Colors.green; // Bonne réponse
    } else if (widget.selectedOptionIndex == optionIndex) {
      return Colors.red; // Mauvaise réponse sélectionnée
    }

    return Colors.grey[300]!; // Option non sélectionnée
  }

  // Détermine la couleur du texte
  Color _getTextColor(int optionIndex) {
    if (!widget.showCorrectAnswer && widget.selectedOptionIndex == optionIndex) {
      return Colors.white;
    }
    return AppTheme.textPrimaryColor;
  }

  // Construit un indicateur de progression
  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texte de progression
          Text(
            'Question ${widget.questionNumber} sur ${widget.totalQuestions}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),

          // Barre de progression
          LinearProgressIndicator(
            value: widget.questionNumber / widget.totalQuestions,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur de progression
            _buildProgressIndicator(),

            // Texte de la question
            Text(
              widget.question.question,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Options de réponse
            ...List.generate(
              widget.question.options.length,
                  (index) => _buildOptionItem(index),
            ),
          ],
        ),
      ),
    );
  }

  // Construction d'une option de réponse
  Widget _buildOptionItem(int index) {
    final isVraiOrFaux = widget.question.type == QuestionType.trueFalse;

    return GestureDetector(
      onTap: () {
        if (!widget.showCorrectAnswer) {
          widget.onOptionSelected(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: _getOptionColor(index),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(index),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icône pour option vrai/faux
            if (isVraiOrFaux)
              Icon(
                widget.question.options[index].toLowerCase() == 'vrai'
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: _getTextColor(index),
                size: 24,
              ),

            // Lettre ou numéro de l'option
            if (!isVraiOrFaux)
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.selectedOptionIndex == index
                      ? Colors.white
                      : AppTheme.primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: widget.selectedOptionIndex == index
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D...
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.selectedOptionIndex == index
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // Texte de l'option
            Expanded(
              child: Text(
                widget.question.options[index],
                style: TextStyle(
                  fontSize: 16,
                  color: _getTextColor(index),
                  fontWeight: widget.selectedOptionIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),

            // Icône de vérification pour afficher la réponse correcte
            if (widget.showCorrectAnswer)
              Icon(
                index == widget.question.correctOptionIndex
                    ? Icons.check_circle
                    : (widget.selectedOptionIndex == index
                    ? Icons.cancel
                    : null),
                color: index == widget.question.correctOptionIndex
                    ? Colors.green
                    : Colors.red,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}