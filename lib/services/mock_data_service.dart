import '../models/index.dart';

// Service contenant toutes les données mockées pour le prototype
class MockDataService {
  // Singleton pattern
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _initMockData();
  }

  // Collections de données
  final List<User> _users = [];
  final List<Category> _categories = [];
  final List<Course> _courses = [];

  // Getters pour accéder aux données
  List<User> get users => _users; // Permettre la modification par les services
  List<Category> get categories => List.unmodifiable(_categories);
  List<Course> get courses => List.unmodifiable(_courses);

  // Méthode d'initialisation des données mockées
  void _initMockData() {
    // Initialiser les catégories
    _initCategories();

    // Initialiser les cours
    _initCourses();

    // Initialiser les utilisateurs
    _initUsers();
  }

  // Initialisation des catégories
  void _initCategories() {
    _categories.addAll([
      Category(
        id: 'cat-1',
        name: 'Arabe',
        description: 'Apprenez la langue arabe à travers des cours structurés et progressifs.',
        imageUrl: 'assets/images/arabic.jpg',
        iconName: 'book',
      ),
      Category(
        id: 'cat-2',
        name: 'Coran',
        description: 'Découvrez et mémorisez le Coran avec des méthodes pédagogiques adaptées.',
        imageUrl: 'assets/images/quran.jpg',
        iconName: 'auto_stories',
      ),
      Category(
        id: 'cat-3',
        name: 'Culture générale',
        description: 'Enrichissez vos connaissances sur la culture et l\'histoire islamique.',
        imageUrl: 'assets/images/culture.jpg',
        iconName: 'school',
      ),
    ]);
  }

  // Initialisation des cours
  void _initCourses() {
    // Cours d'arabe
    _courses.addAll([
      Course(
        id: 'course-1',
        title: 'L\'alphabet arabe',
        description: 'Apprenez les bases de l\'alphabet arabe et comment écrire vos premières lettres.',
        categoryId: 'cat-1',
        level: 'beginner',
        imageUrl: 'assets/images/arabic_alphabet.jpg',
        videoUrl: 'https://example.com/video1.mp4',
        pdfUrl: 'assets/pdf/arabic_alphabet.pdf',
        durationMinutes: 45,
        lessons: [
          Lesson(
            id: 'lesson-1-1',
            title: 'Introduction à l\'alphabet arabe',
            content: 'L\'alphabet arabe comporte 28 lettres qui s\'écrivent de droite à gauche...',
            orderIndex: 0,
            durationMinutes: 10,
          ),
          Lesson(
            id: 'lesson-1-2',
            title: 'Les lettres initiales',
            content: 'Nous allons apprendre les premières lettres de l\'alphabet...',
            orderIndex: 1,
            durationMinutes: 15,
          ),
          Lesson(
            id: 'lesson-1-3',
            title: 'Exercices d\'écriture',
            content: 'Pratiquons l\'écriture des lettres que nous avons apprises...',
            orderIndex: 2,
            durationMinutes: 20,
          ),
        ],
        quiz: Quiz(
          id: 'quiz-1',
          title: 'Quiz sur l\'alphabet arabe',
          description: 'Testez vos connaissances sur les lettres arabes.',
          questions: [
            QuizQuestion(
              id: 'q1-1',
              question: 'Combien de lettres comporte l\'alphabet arabe ?',
              options: ['26', '28', '29', '30'],
              correctOptionIndex: 1,
              type: QuestionType.multipleChoice,
            ),
            QuizQuestion(
              id: 'q1-2',
              question: 'Quelle est la première lettre de l\'alphabet arabe ?',
              options: ['ب (Ba)', 'أ (Alif)', 'ت (Ta)', 'ث (Tha)'],
              correctOptionIndex: 1,
              type: QuestionType.multipleChoice,
            ),
            QuizQuestion(
              id: 'q1-3',
              question: 'Dans quelle direction s\'écrit l\'arabe ?',
              options: ['De gauche à droite', 'De droite à gauche', 'De haut en bas', 'De bas en haut'],
              correctOptionIndex: 1,
              type: QuestionType.multipleChoice,
            ),
          ],
        ),
      ),
      // Autres cours d'arabe...
    ]);

    // Ajoutez les autres cours de la même manière...
  }

  // Initialisation des utilisateurs avec le modèle enrichi
  void _initUsers() {
    _users.addAll([
      User(
        id: 'user-1',
        firstName: 'Ahmed',
        lastName: 'Benali',
        email: 'ahmed@example.com',
        username: 'ahmed.benali',
        role: 'student',
        isActive: true,
        gender: 'Masculin',
        birthDate: DateTime(1995, 5, 15),
        creationDate: DateTime.now().subtract(const Duration(days: 180)),
        lastLoginDate: DateTime.now().subtract(const Duration(days: 2)),
        profileImageUrl: 'assets/images/user1.jpg',
        completedCourseIds: ['course-1', 'course-3'],
        completedCourses: ['L\'alphabet arabe', 'Introduction à la récitation'],
        inProgressCourses: ['Les pronoms personnels'],
        quizScores: {
          'quiz-1': 85,
          'quiz-3': 70,
        },
      ),
      User(
        id: 'user-2',
        firstName: 'Fatima',
        lastName: 'Zahra',
        email: 'fatima@example.com',
        username: 'fatima.zahra',
        role: 'student',
        isActive: true,
        gender: 'Féminin',
        birthDate: DateTime(1998, 8, 21),
        creationDate: DateTime.now().subtract(const Duration(days: 150)),
        lastLoginDate: DateTime.now().subtract(const Duration(days: 1)),
        profileImageUrl: 'assets/images/user2.jpg',
        completedCourseIds: ['course-1', 'course-2', 'course-5'],
        completedCourses: ['L\'alphabet arabe', 'Les pronoms personnels', 'Histoire des prophètes'],
        inProgressCourses: ['Les piliers de l\'Islam'],
        quizScores: {
          'quiz-1': 90,
          'quiz-2': 85,
          'quiz-5': 95,
        },
      ),
      User(
        id: 'user-3',
        firstName: 'Mohammed',
        lastName: 'Chakir',
        email: 'mohammed@example.com',
        username: 'mohammed.chakir',
        role: 'parent',
        isActive: true,
        gender: 'Masculin',
        birthDate: DateTime(1980, 3, 10),
        creationDate: DateTime.now().subtract(const Duration(days: 120)),
        lastLoginDate: DateTime.now().subtract(const Duration(days: 3)),
        profileImageUrl: 'assets/images/user3.jpg',
        completedCourseIds: [],
        completedCourses: [],
        inProgressCourses: [],
        quizScores: {},
        childrenIds: ['user-1'],
      ),
    ]);
  }

  // Méthodes d'accès aux données

  // Recherche d'un utilisateur par email
  User? findUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Recherche d'un utilisateur par ID
  User? findUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupération des cours par catégorie
  List<Course> getCoursesByCategory(String categoryId) {
    return _courses.where((course) => course.categoryId == categoryId).toList();
  }

  // Recherche d'un cours par ID
  Course? findCourseById(String id) {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  // Recherche d'une catégorie par ID
  Category? findCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Récupération du quiz d'un cours
  Quiz? getQuizForCourse(String courseId) {
    final course = findCourseById(courseId);
    return course?.quiz;
  }

  // Mise à jour du score d'un quiz pour un utilisateur
  void updateQuizScore(String userId, String quizId, int score) {
    final userIndex = _users.indexWhere((user) => user.id == userId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      final updatedScores = Map<String, int>.from(user.quizScores);
      updatedScores[quizId] = score;

      // Mettre à jour l'utilisateur avec le nouveau score
      _users[userIndex] = user.copyWith(quizScores: updatedScores);

      // Si le score est suffisant, marquer le cours comme complété
      if (score >= 70) {
        // Trouver le cours correspondant au quiz
        Course? courseWithQuiz;
        for (final course in _courses) {
          if (course.quiz.id == quizId) {
            courseWithQuiz = course;
            break;
          }
        }

        if (courseWithQuiz != null) {
          final completedCourseIds = List<String>.from(user.completedCourseIds);
          final completedCourses = List<String>.from(user.completedCourses ?? []);

          if (!completedCourseIds.contains(courseWithQuiz.id)) {
            completedCourseIds.add(courseWithQuiz.id);
            completedCourses.add(courseWithQuiz.title);

            // Mettre à jour l'utilisateur avec le nouveau cours complété
            _users[userIndex] = user.copyWith(
              completedCourseIds: completedCourseIds,
              completedCourses: completedCourses,
            );
          }
        }
      }
    }
  }

  // Ajouter cette méthode pour aider à mettre à jour un utilisateur
  void updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
    } else {
      _users.add(updatedUser);
    }
  }

  // Ajouter un nouvel utilisateur
  void addUser(User user) {
    if (!_users.any((u) => u.id == user.id)) {
      _users.add(user);
    }
  }

  // Supprimer un utilisateur
  bool removeUser(String userId) {
    final initialLength = _users.length;
    _users.removeWhere((user) => user.id == userId);
    return _users.length < initialLength;
  }
}