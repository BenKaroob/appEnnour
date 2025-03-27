import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import 'admin_category_form_page.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({Key? key}) : super(key: key);

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final AdminCourseService _courseService = AdminCourseService();
  final AdminAuthService _authService = AdminAuthService();

  bool _isLoading = true;
  List<Category> _categories = [];
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories from service
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check permissions
      final admin = _authService.currentAdmin;
      if (admin == null || (!admin.hasPermission('read:all') && !admin.hasPermission('read:category'))) {
        setState(() {
          _errorMessage = 'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.';
          _isLoading = false;
        });
        return;
      }

      // Load categories
      final categories = await _courseService.getCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des catégories: $e';
        _isLoading = false;
      });
      print('Erreur de chargement des catégories: $e');
    }
  }

  // Filter categories based on search query
  List<Category> _getFilteredCategories() {
    if (_searchQuery.isEmpty) return _categories;

    return _categories.where((category) {
      final query = _searchQuery.toLowerCase();
      return category.name.toLowerCase().contains(query) ||
          category.description.toLowerCase().contains(query);
    }).toList();
  }

  // Navigate to create new category
  void _navigateToCreateCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCategoryFormPage(isEditing: false),
      ),
    ).then((value) {
      if (value == true) {
        _loadCategories();
      }
    });
  }

// Navigate to edit category
  void _navigateToEditCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCategoryFormPage(
          isEditing: true,
          category: category,
        ),
      ),
    ).then((value) {
      if (value == true) {
        _loadCategories();
      }
    });
  }

  // Delete category
  Future<void> _deleteCategory(Category category) async {
    // Confirmation dialog
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Confirmation de suppression',
      message: 'Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ? '
          'Cette action est irréversible et supprimera tous les cours associés.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (!confirm) return;

    try {
      final success = await _courseService.deleteCategory(category.id);

      if (success) {
        // Show success message
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'La catégorie "${category.name}" a été supprimée avec succès.',
            backgroundColor: Colors.green,
          );
        }

        // Reload categories
        _loadCategories();
      } else {
        // Show error message
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Échec de la suppression de la catégorie.',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Build categories list
  Widget _buildCategoriesList() {
    final filteredCategories = _getFilteredCategories();

    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucune catégorie ne correspond à votre recherche.'
                  : 'Aucune catégorie n\'est disponible actuellement.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text('Réinitialiser la recherche'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToEditCategory(category),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category image or icon
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: category.imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: AssetImage(category.imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: category.imageUrl.isEmpty ? AppTheme.primaryColor.withOpacity(0.1) : null,
                  ),
                  child: category.imageUrl.isEmpty
                      ? Center(
                    child: Icon(
                      Icons.category,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  )
                      : null,
                ),

                // Category details
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action buttons
                const Spacer(),
                if (_authService.currentAdmin?.hasPermission('update:category') == true ||
                    _authService.currentAdmin?.hasPermission('delete:category') == true)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_authService.currentAdmin?.hasPermission('update:category') == true)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Modifier',
                            onPressed: () => _navigateToEditCategory(category),
                          ),
                        if (_authService.currentAdmin?.hasPermission('delete:category') == true)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Supprimer',
                            onPressed: () => _deleteCategory(category),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCreateCategory = _authService.currentAdmin?.hasPermission('create:category') == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des catégories'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
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
      )
          : Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une catégorie...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Categories count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Total: ${_getFilteredCategories().length} catégorie(s)',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Categories grid
          Expanded(
            child: _buildCategoriesList(),
          ),
        ],
      ),
      // Add new category button
      floatingActionButton: canCreateCategory
          ? FloatingActionButton(
        onPressed: _navigateToCreateCategory,
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}