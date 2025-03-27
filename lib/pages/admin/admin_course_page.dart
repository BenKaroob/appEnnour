import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';

class AdminCourseFormPage extends StatefulWidget {
  final bool isEditing;
  final Course? course;

  const AdminCourseFormPage({
    Key? key,
    required this.isEditing,
    this.course,
  }) : super(key: key);

  @override
  State<AdminCourseFormPage> createState() => _AdminCourseFormPageState();
}

class _AdminCourseFormPageState extends State<AdminCourseFormPage> {
  final AdminCourseService _courseService = AdminCourseService();

  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs du formulaire
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _durationController = TextEditingController();

  // État du formulaire
  bool _isLoading = true;
  List<Category> _categories = [];
  String? _selectedCategoryId;
  String _selectedLevel = 'beginner';
  String? _errorMessage;

  // Liste des niveaux disponibles
  final List<Map<String, dynamic>> _levels = [
    {'value': 'beginner', 'label': 'Débutant', 'color': Colors.green},
    {'value': 'intermediate', 'label': 'Intermédiaire', 'color': Colors.orange},
    {'value': 'advanced', 'label': 'Avancé', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();

    // Si nous sommes en mode édition, initialiser les champs avec les données du cours
    if (widget.isEditing && widget.course != null) {
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _imageUrlController.text = widget.course!.imageUrl;
      _videoUrlController.text = widget.course!.videoUrl;
      _pdfUrlController.text = widget.course!.pdfUrl;
      _durationController.text = widget.course!.durationMinutes.toString();
      _selectedCategoryId = widget.course!.categoryId;
      _selectedLevel = widget.course!.level;
    }

    _loadCategories();
  }

  @override
  void dispose() {
    // Libérer les ressources
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _pdfUrlController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // Chargement des catégories
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les catégories
      final categories = await _courseService.getCategories();

      setState(() {
        _categories = categories;
        // Si nous sommes en mode création et qu'il y a des catégories, sélectionner la première par défaut
        if (!widget.isEditing && _selectedCategoryId == null && categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
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
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final imageUrl = _imageUrlController.text.trim();
      final videoUrl = _videoUrlController.text.trim();
      final pdfUrl = _pdfUrlController.text.trim();
      final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 0;

      // Vérifier qu'une catégorie est sélectionnée
      if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
        setState(() {
          _errorMessage = 'Veuillez sélectionner une catégorie.';
          _isLoading = false;
        });
        return;
      }

      // Créer ou mettre à jour le cours
      if (widget.isEditing && widget.course != null) {
        // Mode édition : mettre à jour le cours existant
        final updatedCourse = widget.course!.copyWith(
          title: title,
          description: description,
          categoryId: _selectedCategoryId!,
          level: _selectedLevel,
          imageUrl: imageUrl,
          videoUrl: videoUrl,
          pdfUrl: pdfUrl,
          durationMinutes: durationMinutes,
        );

        await _courseService.updateCourse(updatedCourse);

        if (mounted) {
          // Afficher un message de succès
          AppUtils.showSnackBar(
            context,
            'Le cours a été mis à jour avec succès.',
            backgroundColor: Colors.green,
          );

          // Retourner à l'écran précédent
          Navigator.pop(context);
        }
      } else {
        // Mode création : créer un nouveau cours
        // Dans une vraie application, l'ID serait généré par le backend
        final newCourseId = 'course-${DateTime.now().millisecondsSinceEpoch}';

        final newCourse = Course(
          id: newCourseId,
          title: title,
          description: description,
          categoryId: _selectedCategoryId!,
          level: _selectedLevel,
          imageUrl: imageUrl,
          videoUrl: videoUrl,
          pdfUrl: pdfUrl,
          durationMinutes: durationMinutes,
          lessons: [], // Initialement, pas de leçons
          quiz: Quiz( // Quiz vide par défaut
            id: 'quiz-$newCourseId',
            title: 'Quiz - $title',
            description: 'Quiz pour le cours $title',
            questions: [],
          ),
        );

        await _courseService.createCourse(newCourse);

        if (mounted) {
          // Afficher un message de succès
          AppUtils.showSnackBar(
            context,
            'Le cours a été créé avec succès.',
            backgroundColor: Colors.green,
          );

          // Retourner à l'écran précédent
          Navigator.pop(context);
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
        ? 'Modifier le cours'
        : 'Créer un nouveau cours';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _categories.isEmpty
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

              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du cours *',
                  hintText: 'Entrez le titre du cours',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est requis';
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
                  hintText: 'Entrez la description du cours',
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

              // Catégorie
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Catégorie *',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategoryId,
                items: _categories.map((category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La catégorie est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Niveau
              const Text(
                'Niveau *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _levels.map((level) {
                  final isSelected = _selectedLevel == level['value'];

                  return ChoiceChip(
                    label: Text(level['label']),
                    selected: isSelected,
                    selectedColor: level['color'].withOpacity(0.2),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? level['color'] : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedLevel = level['value'];
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Durée
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Durée (en minutes) *',
                  hintText: 'Entrez la durée du cours',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La durée est requise';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
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
                  hintText: 'Entrez l\'URL de l\'image du cours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // URL de la vidéo
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la vidéo',
                  hintText: 'Entrez l\'URL de la vidéo du cours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // URL du PDF
              TextFormField(
                controller: _pdfUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL du PDF',
                  hintText: 'Entrez l\'URL du PDF du cours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Note informative
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
                        widget.isEditing
                            ? 'La modification des leçons et du quiz peut être effectuée depuis la page de détail du cours.'
                            : 'Vous pourrez ajouter des leçons et configurer le quiz après avoir créé le cours.',
                        style: TextStyle(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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