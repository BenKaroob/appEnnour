import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';

class AdminCategoryFormPage extends StatefulWidget {
  final Category? category;
  final bool isEditing;

  const AdminCategoryFormPage({
    Key? key,
    this.category,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AdminCategoryFormPage> createState() => _AdminCategoryFormPageState();
}

class _AdminCategoryFormPageState extends State<AdminCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminCourseService _courseService = AdminCourseService();

  // Contrôleurs pour les champs du formulaire
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _iconNameController;

  // État du formulaire
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs avec les valeurs de la catégorie si en mode édition
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.category?.imageUrl ?? '');
    _iconNameController = TextEditingController(text: widget.category?.iconName ?? '');
  }

  @override
  void dispose() {
    // Libérer les contrôleurs à la destruction du widget
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _iconNameController.dispose();
    super.dispose();
  }

  // Soumission du formulaire
  Future<void> _submitForm() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer les valeurs du formulaire
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final imageUrl = _imageUrlController.text.trim();
      final iconName = _iconNameController.text.trim();

      if (widget.isEditing && widget.category != null) {
        // Mode édition : mettre à jour la catégorie existante
        final updatedCategory = widget.category!.copyWith(
          name: name,
          description: description,
          imageUrl: imageUrl,
          iconName: iconName,
        );

        await _courseService.updateCategory(updatedCategory);

        if (mounted) {
          // Afficher un message de succès
          AppUtils.showSnackBar(
            context,
            'La catégorie a été mise à jour avec succès.',
            backgroundColor: Colors.green,
          );

          // Retourner à l'écran précédent
          Navigator.pop(context, true);
        }
      } else {
        // Mode création : créer une nouvelle catégorie
        // Dans une vraie application, l'ID serait généré par le backend
        final categoryId = 'category-${DateTime.now().millisecondsSinceEpoch}';

        final newCategory = Category(
          id: categoryId,
          name: name,
          description: description,
          imageUrl: imageUrl,
          iconName: iconName,
        );

        await _courseService.createCategory(newCategory);

        if (mounted) {
          // Afficher un message de succès
          AppUtils.showSnackBar(
            context,
            'La catégorie a été créée avec succès.',
            backgroundColor: Colors.green,
          );

          // Retourner à l'écran précédent
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
      print('Erreur lors de la soumission du formulaire: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.isEditing
        ? 'Modifier la catégorie'
        : 'Créer une nouvelle catégorie';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message d'erreur
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Nom de la catégorie
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie *',
                  hintText: 'Entrez le nom de la catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Entrez la description de la catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL de l'image
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image',
                  hintText: 'Entrez l\'URL de l\'image de la catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Nom de l'icône
              TextFormField(
                controller: _iconNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'icône',
                  hintText: 'Entrez le nom de l\'icône (ex: book, school)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Note explicative pour les icônes
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Les noms d\'icônes disponibles sont: book, auto_stories, school, etc. Ces noms correspondent aux icônes Material Design de Flutter.',
                        style: TextStyle(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        widget.isEditing ? 'Mettre à jour' : 'Créer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}