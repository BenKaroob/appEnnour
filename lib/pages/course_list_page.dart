import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../utils/index.dart';
import '../widgets/index.dart';

// Page affichant la liste des cours d'une catégorie spécifique
class CourseListPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CourseListPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final CourseService _courseService = CourseService();
  final UserService _userService = UserService();

  bool _isLoading = true;
  List<Course> _courses = [];
  String? _errorMessage;
  Map<String, bool> _completedCoursesMap = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Chargement des cours et de l'état de complétion
  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les cours pour cette catégorie
      final courses = await _courseService.getCoursesByCategory(widget.categoryId);

      // Vérifier les cours complétés par l'utilisateur
      final completedMap = <String, bool>{};
      for (final course in courses) {
        completedMap[course.id] = await _userService.hasCompletedCourse(course.id);
      }

      setState(() {
        _courses = courses;
        _completedCoursesMap = completedMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des cours';
        _isLoading = false;
      });
      print('Erreur de chargement des cours: $e');
    }
  }

  // Navigation vers le détail d'un cours
  void _navigateToCourseDetail(Course course) {
    AppRoutes.navigateToCourseDetail(context, course.id);
  }

  // Construction de la liste des cours
  Widget _buildCoursesList() {
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
              onPressed: _loadCourses,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun cours disponible dans cette catégorie',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Trier les cours par niveau
    final sortedCourses = List<Course>.from(_courses)
      ..sort((a, b) {
        final levelOrder = {
          'beginner': 0,
          'intermediate': 1,
          'advanced': 2,
        };
        return (levelOrder[a.level] ?? 0).compareTo(levelOrder[b.level] ?? 0);
      });

    return ListView.builder(
      itemCount: sortedCourses.length,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
      itemBuilder: (context, index) {
        final course = sortedCourses[index];
        final isCompleted = _completedCoursesMap[course.id] ?? false;

        return CourseCard(
          course: course,
          isCompleted: isCompleted,
          onTap: () => _navigateToCourseDetail(course),
        );
      },
    );
  }

  // Construction des filtres de niveau
  Widget _buildLevelFilters() {
    final levels = _courses.map((c) => c.level).toSet().toList();

    if (levels.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
      child: Row(
        children: [
          // Filtrer par niveau
          ...levels.map((level) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(AppUtils.translateLevel(level)),
                onSelected: (selected) {
                  // Pour l'instant, ne fait rien car c'est un prototype
                  // À implémenter dans une version future
                },
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: widget.categoryName,
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête avec titre de section
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explorez nos cours ${widget.categoryName.toLowerCase()}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sélectionnez un cours pour commencer à apprendre',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Filtres de niveau (inactifs pour le prototype)
          if (!_isLoading && _errorMessage == null && _courses.isNotEmpty)
            _buildLevelFilters(),

          // Liste des cours
          Expanded(
            child: _buildCoursesList(),
          ),
        ],
      ),
    );
  }
}