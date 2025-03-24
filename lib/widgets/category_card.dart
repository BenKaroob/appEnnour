import 'package:flutter/material.dart';
import '../models/index.dart';
import '../utils/index.dart';

// Widget réutilisable pour afficher une catégorie de cours
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Liste de couleurs pour les catégories au cas où aucune n'est fournie
    final List<Color> defaultColors = [
      const Color(0xFF1A237E), // Bleu foncé pour Arabe
      const Color(0xFF004D40), // Vert foncé pour Coran
      const Color(0xFF311B92), // Violet pour Culture générale
    ];

    // Détermine la couleur à utiliser
    final Color cardColor = backgroundColor ??
        defaultColors[int.parse(category.id.split('-')[1]) % defaultColors.length];

    // Récupère l'icône appropriée
    final IconData iconData = AppUtils.getCategoryIcon(category.iconName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: AppTheme.categoryCardDecoration(cardColor),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          child: Stack(
            children: [
              // Fond avec image (optionnel)
              if (category.imageUrl.isNotEmpty)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2, // Image en filigrane
                    child: Image.asset(
                      category.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback si l'image n'est pas trouvée
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

              // Contenu de la carte
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icône de la catégorie
                    Icon(
                      iconData,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),

                    // Nom de la catégorie
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description de la catégorie
                    Text(
                      category.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Bouton pour explorer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explorer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}