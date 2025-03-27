import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';

class AdminLessonFormPage extends StatefulWidget {
  final String courseId;
  final bool isEditing;
  final Lesson? lesson;

  const AdminLessonFormPage({
    Key? key,
    required this.courseId,
    required this.isEditing,
    this.lesson,
  }) : super(key: key);

  @override
  State<AdminLessonFormPage> createState() => _AdminLessonFormPageState();
}

class _AdminLessonFormPageState extends State<AdminLessonFormPage> {
  final AdminCourseService _courseService = AdminCourseService();

  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs du formulaire
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _orderIndexController = TextEditingController();
  final _durationController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // État du formulaire
  bool _isLoading = false;
  String? _errorMessage;
  Course? _course;
  int _maxOrderIndex = 0;

  @override
  void initState() {
    super.initState();

    // Si nous sommes en mode édition, initialiser les champs avec les données de la leçon
    if (widget.isEditing && widget.lesson != null) {
      _titleController.text = widget.lesson!.title;
      _contentController.text = widget.lesson!.content;
      _orderIndexController.text = widget.lesson!.orderIndex.toString();
      _durationController.text = widget.lesson!.durationMinutes.toString();
      _videoUrlController.text = widget.lesson!.videoUrl ?? '';
      _imageUrlController.text = widget.lesson!.imageUrl ?? '';
    } else {
      // En mode création, initialiser l'index d'ordre à la fin de la liste
      _loadCourse();
    }
  }

  @override
  void dispose() {
    // Libérer les ressources
    _titleController.dispose();
    _contentController.dispose();
    _orderIndexController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Chargement du cours pour obtenir les informations sur les leçons existantes
  Future<void> _loadCourse() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger le cours
      final course = await _courseService.getCourseById(widget.courseId);

      if (course == null) {
        setState(() {
          _errorMessage = 'Cours non trouvé';
          _isLoading = false;
        });
        return;
      }

      // Déterminer le prochain index d'ordre disponible
      _maxOrderIndex = 0;
      if (course.lessons.isNotEmpty) {
        for (final lesson in course.lessons) {
          if (lesson.orderIndex > _maxOrderIndex) {
            _maxOrderIndex = lesson.orderIndex;
          }
        }
      }

      // Initialiser l'index d'ordre pour la nouvelle leçon
      if (!widget.isEditing) {
        _orderIndexController.text = (_maxOrderIndex + 1).toString();
      }

      setState(() {
        _course = course;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du cours: $e';
        _isLoading = false;
      });
      print('Erreur de chargement du cours: $e');
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
      final content = _contentController.text.trim();
      final orderIndex = int.tryParse(_orderIndexController.text.trim()) ?? 0;
      final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 0;
      final videoUrl = _videoUrlController.text.trim().isNotEmpty ? _videoUrlController.text.trim() : null;
      final imageUrl = _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null;

      if (widget.isEditing && widget.lesson != null) {
        // Mode édition : mettre à jour la leçon existante
        final updatedLesson = widget.lesson!.copyWith(
          title: title,
          content: content,
          orderIndex: orderIndex,
          durationMinutes: durationMinutes,
          videoUrl: videoUrl,
          imageUrl: imageUrl,
        );

        await _courseService.updateLesson(widget.courseId, updatedLesson);

        if (mounted) {
          // Afficher un message de succès
          AppUtils.showSnackBar(
            context,
            'La leçon a été mise à jour avec succès.',
            backgroundColor: Colors.green,
          );

          // Retourner à l'écran précédent
          Navigator.pop(context);
        }
      } else {
        // Mode création : créer une nouvelle leçon
        // Dans une vraie application, l'ID serait généré par le backend
        final newLessonId = 'lesson-${DateTime.now().millisecondsSinceEpoch}';

        final newLesson = Lesson(
          id: newLessonId,
          title: title,
          content: content,
          orderIndex: orderIndex,
          durationMinutes: durationMinutes,
          videoUrl: videoUrl,
          imageUrl: imageUrl,
        );

        await _courseService.addLessonToCourse(widget.courseId, newLesson);

        if (mounted) {
          // Afficher un message de succès
          AppUtils.showSnackBar(
            context,
            'La leçon a été créée avec succès.',
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
        ? 'Modifier la leçon'
        : 'Ajouter une leçon';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading && _course == null && !widget.isEditing
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _course == null && !widget.isEditing
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
              onPressed: _loadCourse,
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
                  labelText: 'Titre de la leçon *',
                  hintText: 'Entrez le titre de la leçon',
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

              // Contenu
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Contenu *',
                  hintText: 'Entrez le contenu de la leçon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le contenu est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ordre d'affichage et durée (2 colonnes)
              Row(
                children: [
                  // Ordre d'affichage
                  Expanded(
                    child: TextFormField(
                      controller: _orderIndexController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ordre d\'affichage *',
                        hintText: 'Ex: 1, 2, 3...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'ordre est requis';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Durée
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durée (minutes) *',
                        hintText: 'Ex: 15, 30, 45...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La durée est requise';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // URL de la vidéo
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la vidéo (optionnel)',
                  hintText: 'Entrez l\'URL de la vidéo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // URL de l'image
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image (optionnel)',
                  hintText: 'Entrez l\'URL de l\'image',
                  border: OutlineInputBorder(),
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
                        widget.isEditing ? 'Mettre à jour' : 'Ajouter',
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