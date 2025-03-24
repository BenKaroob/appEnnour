import 'package:flutter/material.dart';
import '../models/index.dart';
import '../utils/index.dart';

// Widget pour afficher un élément de leçon dans une liste
class LessonListItem extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isCompleted;

  const LessonListItem({
    Key? key,
    required this.lesson,
    required this.index,
    this.onTap,
    this.isActive = false,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Numéro ou icône de statut de la leçon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(),
              ),
              alignment: Alignment.center,
              child: _getStatusIcon(),
            ),
            const SizedBox(width: 12),

            // Contenu de la leçon
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la leçon
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                    ),
                  ),

                  // Durée de la leçon
                  if (lesson.durationMinutes > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppUtils.formatDuration(lesson.durationMinutes),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Indicateur de type de média
            if (lesson.videoUrl != null || lesson.imageUrl != null)
              Icon(
                lesson.videoUrl != null ? Icons.videocam : Icons.image,
                color: AppTheme.accentColor,
                size: 20,
              ),

            // Flèche pour indiquer la navigation
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Détermine la couleur du cercle de statut
  Color _getStatusColor() {
    if (isCompleted) {
      return AppTheme.secondaryColor;
    } else if (isActive) {
      return AppTheme.primaryColor;
    } else {
      return Colors.grey[300]!;
    }
  }

  // Détermine l'icône ou le texte à afficher dans le cercle de statut
  Widget _getStatusIcon() {
    if (isCompleted) {
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      );
    } else {
      return Text(
        '${index + 1}',
        style: TextStyle(
          color: isActive ? Colors.white : AppTheme.textSecondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
  }
}