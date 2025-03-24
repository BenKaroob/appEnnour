import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../utils/index.dart';
import '../widgets/index.dart';

// Page d'accueil principale de l'application
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CourseService _courseService = CourseService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  List<Category> _categories = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Chargement des catégories
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _courseService.getCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des catégories';
        _isLoading = false;
      });
      print('Erreur de chargement des catégories: $e');
    }
  }

  // Déconnexion de l'utilisateur
  Future<void> _handleLogout() async {
    final bool confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Déconnexion',
      cancelText: 'Annuler',
    );

    if (confirm) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // Navigation vers une page de liste de cours par catégorie
  void _navigateToCourseList(Category category) {
    AppRoutes.navigateToCourseList(
      context,
      category.id,
      category.name,
    );
  }

  // Construction de la liste des catégories
  Widget _buildCategoriesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text('Aucune catégorie disponible'),
      );
    }

    // Utilisation d'un GridView pour adapter l'affichage aux tablettes également
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapter la disposition selon la largeur
        final isTablet = constraints.maxWidth > 600;
        final crossAxisCount = isTablet ? 2 : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: isTablet ? 1.5 : 1.2,
          ),
          itemCount: _categories.length,
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          itemBuilder: (context, index) {
            final category = _categories[index];

            // Utilisation de couleurs différentes pour chaque catégorie
            final List<Color> categoryColors = [
              const Color(0xFF1A237E), // Bleu foncé
              const Color(0xFF004D40), // Vert foncé
              const Color(0xFF311B92), // Violet
            ];

            final categoryColor = categoryColors[index % categoryColors.length];

            return CategoryCard(
              category: category,
              backgroundColor: categoryColor,
              onTap: () => _navigateToCourseList(category),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir l'utilisateur actuel
    final currentUser = _authService.currentUser;
    final userName = currentUser?.name ?? 'Étudiant';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: AppConstants.appName,
        showBackButton: false,
        showBismillah: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête avec accueil personnalisé
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salam, $userName !',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Que souhaitez-vous apprendre aujourd\'hui ?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Ligne avec bismillah stylisée
          const BismillahHeader(
            isCompact: true,
          ),

          // Liste des catégories
          Expanded(
            child: _buildCategoriesList(),
          ),
        ],
      ),
    );
  }
}