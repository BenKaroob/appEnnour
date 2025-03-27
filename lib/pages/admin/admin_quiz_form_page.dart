import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';

class AdminQuizFormPage extends StatefulWidget {
  final String courseId;
  final Quiz quiz;

  const AdminQuizFormPage({
    Key? key,
    required this.courseId,
    required this.quiz,
  }) : super(key: key);

  @override
  State<AdminQuizFormPage> createState() => _AdminQuizFormPageState();
}

class _AdminQuizFormPageState extends State<AdminQuizFormPage> {
  final AdminCourseService _courseService = AdminCourseService();

  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs du formulaire principal
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // État du formulaire
  bool _isLoading = false;
  String? _errorMessage;

  // Liste des questions (modifiable)
  List<QuizQuestion> _questions = [];

  // État pour l'ajout/modification de question
  bool _editingQuestion = false;
  int? _editingQuestionIndex;
  String _questionText = '';
  List<String> _options = ['', ''];
  int _correctOptionIndex = 0;
  QuestionType _questionType = QuestionType.multipleChoice;

  @override
  void initState() {
    super.initState();

    // Initialiser les champs avec les données du quiz
    _titleController.text = widget.quiz.title;
    _descriptionController.text = widget.quiz.description;

    // Copier les questions pour pouvoir les modifier
    _questions = List.from(widget.quiz.questions);
  }

  @override
  void dispose() {
    // Libérer les ressources
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Méthode pour soumettre le formulaire principal
  Future<void> _submitQuiz() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Créer le quiz mis à jour
      final updatedQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        questions: _questions,
      );

      // Mettre à jour le quiz
      await _courseService.updateQuiz(widget.courseId, updatedQuiz);

      if (mounted) {
        // Afficher un message de succès
        AppUtils.showSnackBar(
          context,
          'Le quiz a été mis à jour avec succès.',
          backgroundColor: Colors.green,
        );

        // Retourner à l'écran précédent
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
      print('Erreur lors de la mise à jour du quiz: $e');
    }
  }

  // Méthode pour ajouter ou mettre à jour une question
  void _showQuestionDialog({QuizQuestion? question, int? index}) {
    // Si on modifie une question existante, initialiser les champs
    if (question != null && index != null) {
      _questionText = question.question;
      _options = List.from(question.options);
      _correctOptionIndex = question.correctOptionIndex;
      _questionType = question.type;
      _editingQuestionIndex = index;
    } else {
      // Sinon, réinitialiser les champs
      _questionText = '';
      _options = _questionType == QuestionType.trueFalse ? ['Vrai', 'Faux'] : ['', ''];
      _correctOptionIndex = 0;
      _questionType = QuestionType.multipleChoice;
      _editingQuestionIndex = null;
    }

    setState(() {
      _editingQuestion = true;
    });
  }

  // Méthode pour sauvegarder la question éditée
  void _saveQuestion() {
    // Vérifier que la question est valide
    if (_questionText.trim().isEmpty) {
      AppUtils.showSnackBar(
        context,
        'Veuillez saisir le texte de la question.',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Vérifier que toutes les options sont remplies
    for (int i = 0; i < _options.length; i++) {
      if (_options[i].trim().isEmpty) {
        AppUtils.showSnackBar(
          context,
          'Veuillez remplir toutes les options.',
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    // Créer la question
    final question = QuizQuestion(
      id: _editingQuestionIndex != null
          ? _questions[_editingQuestionIndex!].id
          : 'question-${DateTime.now().millisecondsSinceEpoch}',
      question: _questionText.trim(),
      options: _options.map((o) => o.trim()).toList(),
      correctOptionIndex: _correctOptionIndex,
      type: _questionType,
    );

    setState(() {
      if (_editingQuestionIndex != null) {
        // Mettre à jour une question existante
        _questions[_editingQuestionIndex!] = question;
      } else {
        // Ajouter une nouvelle question
        _questions.add(question);
      }

      // Réinitialiser l'état d'édition
      _editingQuestion = false;
      _editingQuestionIndex = null;
    });
  }

  // Méthode pour supprimer une question
  void _deleteQuestion(int index) {
    // Demander confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette question ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _questions.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Construction du formulaire d'édition de question
  Widget _buildQuestionEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _editingQuestionIndex != null
                    ? 'Modifier la question ${_editingQuestionIndex! + 1}'
                    : 'Ajouter une nouvelle question',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _editingQuestion = false;
                    _editingQuestionIndex = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type de question
          const Text(
            'Type de question',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<QuestionType>(
            segments: const [
              ButtonSegment<QuestionType>(
                value: QuestionType.multipleChoice,
                label: Text('Choix multiple'),
                icon: Icon(Icons.checklist),
              ),
              ButtonSegment<QuestionType>(
                value: QuestionType.trueFalse,
                label: Text('Vrai/Faux'),
                icon: Icon(Icons.rule),
              ),
            ],
            selected: {_questionType},
            onSelectionChanged: (Set<QuestionType> selection) {
              setState(() {
                _questionType = selection.first;

                // Réinitialiser les options si on change de type
                if (_questionType == QuestionType.trueFalse) {
                  _options = ['Vrai', 'Faux'];
                  _correctOptionIndex = 0; // Par défaut "Vrai"
                } else if (_options.length < 2) {
                  _options = ['', ''];
                  _correctOptionIndex = 0;
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Texte de la question
          TextField(
            decoration: const InputDecoration(
              labelText: 'Texte de la question *',
              hintText: 'Saisissez votre question ici',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            controller: TextEditingController(text: _questionText),
            onChanged: (value) {
              _questionText = value;
            },
          ),
          const SizedBox(height: 16),

          // Options de réponse
          const Text(
            'Options de réponse',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Liste des options
          ...List.generate(
            _options.length,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Radio pour sélectionner la bonne réponse
                  Radio<int>(
                    value: index,
                    groupValue: _correctOptionIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value!;
                      });
                    },
                  ),

                  // Lettre ou indicateur de l'option
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _questionType == QuestionType.trueFalse
                            ? (index == 0 ? 'V' : 'F')
                            : String.fromCharCode(65 + index), // A, B, C, D...
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Champ texte de l'option
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _options[index]),
                      onChanged: (value) {
                        setState(() {
                          _options[index] = value;
                        });
                      },
                      enabled: _questionType != QuestionType.trueFalse,
                    ),
                  ),

                  // Bouton pour supprimer l'option
                  if (_questionType != QuestionType.trueFalse && _options.length > 2)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _options.removeAt(index);
                          if (_correctOptionIndex >= _options.length) {
                            _correctOptionIndex = 0;
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          // Bouton pour ajouter une option
          if (_questionType != QuestionType.trueFalse && _options.length < 6)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _options.add('');
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une option'),
            ),

          const SizedBox(height: 24),

          // Boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _editingQuestion = false;
                    _editingQuestionIndex = null;
                  });
                },
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                ),
                child: Text(
                  _editingQuestionIndex != null ? 'Mettre à jour' : 'Ajouter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Construction de la liste des questions
  Widget _buildQuestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec bouton d'ajout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Questions (${_questions.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showQuestionDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Message si aucune question
        if (_questions.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.help_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune question n\'a encore été ajoutée à ce quiz.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

        // Liste des questions
        ...List.generate(
          _questions.length,
              (index) {
            final question = _questions[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numéro et type de question
                    Row(
                      children: [
                        // Numéro
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Texte de la question (résumé)
                        Expanded(
                          child: Text(
                            question.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Badge du type
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            question.type == QuestionType.multipleChoice
                                ? 'Choix multiple'
                                : 'Vrai/Faux',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Options (résumé)
                    ...List.generate(
                      question.options.length,
                          (optionIndex) {
                        final isCorrect = optionIndex == question.correctOptionIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              // Indicateur (correct ou non)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCorrect ? Colors.green : Colors.grey[300],
                                ),
                                child: Center(
                                  child: isCorrect
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : Text(
                                    question.type == QuestionType.trueFalse
                                        ? (optionIndex == 0 ? 'V' : 'F')
                                        : String.fromCharCode(65 + optionIndex),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Texte de l'option
                              Expanded(
                                child: Text(
                                  question.options[optionIndex],
                                  style: TextStyle(
                                    color: isCorrect ? Colors.green[800] : null,
                                    fontWeight: isCorrect ? FontWeight.bold : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Boutons d'action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showQuestionDialog(
                            question: question,
                            index: index,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _deleteQuestion(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le quiz'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _editingQuestion
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildQuestionEditor(),
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

              // Titre du quiz
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du quiz *',
                  hintText: 'Entrez le titre du quiz',
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

              // Description du quiz
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description du quiz *',
                  hintText: 'Entrez la description du quiz',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Séparateur
              const Divider(),
              const SizedBox(height: 16),

              // Liste des questions
              _buildQuestionsList(),
              const SizedBox(height: 24),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitQuiz,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      : const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}