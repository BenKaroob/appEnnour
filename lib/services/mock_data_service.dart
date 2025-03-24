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
  List<User> get users => List.unmodifiable(_users);
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
            ),
            QuizQuestion(
              id: 'q1-2',
              question: 'Quelle est la première lettre de l\'alphabet arabe ?',
              options: ['ب (Ba)', 'أ (Alif)', 'ت (Ta)', 'ث (Tha)'],
              correctOptionIndex: 1,
            ),
            QuizQuestion(
              id: 'q1-3',
              question: 'Dans quelle direction s\'écrit l\'arabe ?',
              options: ['De gauche à droite', 'De droite à gauche', 'De haut en bas', 'De bas en haut'],
              correctOptionIndex: 1,
            ),
          ],
        ),
      ),
      Course(
        id: 'course-2',
        title: 'Les pronoms personnels',
        description: 'Maîtrisez les pronoms personnels en arabe et leur utilisation dans les phrases.',
        categoryId: 'cat-1',
        level: 'intermediate',
        imageUrl: 'assets/images/arabic_pronouns.jpg',
        videoUrl: 'https://example.com/video2.mp4',
        pdfUrl: 'assets/pdf/arabic_pronouns.pdf',
        durationMinutes: 60,
        lessons: [
          Lesson(
            id: 'lesson-2-1',
            title: 'Les pronoms singuliers',
            content: 'Découvrons les pronoms personnels singuliers en arabe...',
            orderIndex: 0,
            durationMinutes: 20,
          ),
          Lesson(
            id: 'lesson-2-2',
            title: 'Les pronoms pluriels',
            content: 'Continuons avec les pronoms personnels pluriels...',
            orderIndex: 1,
            durationMinutes: 20,
          ),
          Lesson(
            id: 'lesson-2-3',
            title: 'Utilisation dans les phrases',
            content: 'Apprenons à utiliser les pronoms dans des phrases complètes...',
            orderIndex: 2,
            durationMinutes: 20,
          ),
        ],
        quiz: Quiz(
          id: 'quiz-2',
          title: 'Quiz sur les pronoms',
          description: 'Testez vos connaissances sur les pronoms en arabe.',
          questions: [
            QuizQuestion(
              id: 'q2-1',
              question: 'Comment dit-on "je" en arabe ?',
              options: ['أنت (Anta)', 'أنا (Ana)', 'هو (Huwa)', 'هي (Hiya)'],
              correctOptionIndex: 1,
            ),
            QuizQuestion(
              id: 'q2-2',
              question: 'Quelle est la forme correcte pour "vous" (pluriel masculin) ?',
              options: ['أنتم (Antum)', 'أنتن (Antunna)', 'هم (Hum)', 'نحن (Nahnu)'],
              correctOptionIndex: 0,
            ),
            QuizQuestion(
              id: 'q2-3',
              question: 'Le pronom "هي" (Hiya) se réfère à :',
              options: ['Il', 'Elle', 'Tu (féminin)', 'Nous'],
              correctOptionIndex: 1,
            ),
          ],
        ),
      ),
    ]);

    // Cours de Coran
    _courses.addAll([
      Course(
        id: 'course-3',
        title: 'Introduction à la récitation',
        description: 'Apprenez les règles de base pour réciter correctement le Coran.',
        categoryId: 'cat-2',
        level: 'beginner',
        imageUrl: 'assets/images/quran_recitation.jpg',
        videoUrl: 'https://example.com/video3.mp4',
        pdfUrl: 'assets/pdf/quran_recitation.pdf',
        durationMinutes: 50,
        lessons: [
          Lesson(
            id: 'lesson-3-1',
            title: 'Les règles de prononciation (Tajwid)',
            content: 'Le Tajwid est l\'ensemble des règles régissant la prononciation correcte du Coran...',
            orderIndex: 0,
            durationMinutes: 15,
          ),
          Lesson(
            id: 'lesson-3-2',
            title: 'Les points d\'arrêt',
            content: 'Apprenons à reconnaître les différents signes d\'arrêt dans le Coran...',
            orderIndex: 1,
            durationMinutes: 20,
          ),
          Lesson(
            id: 'lesson-3-3',
            title: 'Exercices pratiques',
            content: 'Mettons en pratique les règles apprises avec des versets simples...',
            orderIndex: 2,
            durationMinutes: 15,
          ),
        ],
        quiz: Quiz(
          id: 'quiz-3',
          title: 'Quiz sur la récitation',
          description: 'Testez vos connaissances sur les règles de récitation.',
          questions: [
            QuizQuestion(
              id: 'q3-1',
              question: 'Qu\'est-ce que le Tajwid ?',
              options: [
                'Un livre de prières',
                'Les règles de prononciation du Coran',
                'Une méthode de mémorisation',
                'Un type de calligraphie'
              ],
              correctOptionIndex: 1,
            ),
            QuizQuestion(
              id: 'q3-2',
              question: 'Le signe "مـ" indique :',
              options: [
                'Un arrêt obligatoire',
                'Un arrêt recommandé',
                'Il ne faut pas s\'arrêter',
                'Un arrêt permis'
              ],
              correctOptionIndex: 0,
            ),
            QuizQuestion(
              id: 'q3-3',
              question: 'Quelle est la durée d\'un "madd tabiî" (allongement naturel) ?',
              options: ['1 temps', '2 temps', '4 temps', '6 temps'],
              correctOptionIndex: 1,
              type: QuestionType.multipleChoice,
            ),
          ],
        ),
      ),
      Course(
        id: 'course-4',
        title: 'Mémorisation de sourates courtes',
        description: 'Apprenez à mémoriser efficacement les sourates courtes du Coran.',
        categoryId: 'cat-2',
        level: 'beginner',
        imageUrl: 'assets/images/quran_memorization.jpg',
        videoUrl: 'https://example.com/video4.mp4',
        pdfUrl: 'assets/pdf/quran_memorization.pdf',
        durationMinutes: 55,
        lessons: [
          Lesson(
            id: 'lesson-4-1',
            title: 'Techniques de mémorisation',
            content: 'Découvrez différentes méthodes pour mémoriser efficacement le Coran...',
            orderIndex: 0,
            durationMinutes: 15,
          ),
          Lesson(
            id: 'lesson-4-2',
            title: 'Sourate Al-Fatiha',
            content: 'Mémorisons ensemble la sourate Al-Fatiha, l\'ouverture du Coran...',
            orderIndex: 1,
            durationMinutes: 20,
          ),
          Lesson(
            id: 'lesson-4-3',
            title: 'Les trois Qul (Al-Ikhlas, Al-Falaq, An-Nas)',
            content: 'Apprenons les trois dernières sourates du Coran...',
            orderIndex: 2,
            durationMinutes: 20,
          ),
        ],
        quiz: Quiz(
          id: 'quiz-4',
          title: 'Quiz sur les sourates courtes',
          description: 'Testez vos connaissances sur les sourates apprises.',
          questions: [
            QuizQuestion(
              id: 'q4-1',
              question: 'Combien de versets comporte la sourate Al-Fatiha ?',
              options: ['5', '6', '7', '8'],
              correctOptionIndex: 2,
            ),
            QuizQuestion(
              id: 'q4-2',
              question: 'La sourate Al-Ikhlas parle principalement de :',
              options: [
                'La protection contre le mal',
                'L\'unicité d\'Allah',
                'Le Jour du Jugement',
                'Les bienfaits du Paradis'
              ],
              correctOptionIndex: 1,
            ),
            QuizQuestion(
              id: 'q4-3',
              question: 'Quelle est la dernière sourate du Coran ?',
              options: ['Al-Ikhlas', 'Al-Falaq', 'An-Nas', 'Al-Masad'],
              correctOptionIndex: 2,
            ),
          ],
        ),
      ),
    ]);

    // Cours de culture générale
    _courses.addAll([
      Course(
        id: 'course-5',
        title: 'Histoire des prophètes',
        description: 'Découvrez l\'histoire des grands prophètes mentionnés dans le Coran.',
        categoryId: 'cat-3',
        level: 'beginner',
        imageUrl: 'assets/images/prophets.jpg',
        videoUrl: 'https://example.com/video5.mp4',
        pdfUrl: 'assets/pdf/prophets_history.pdf',
        durationMinutes: 65,
        lessons: [
          Lesson(
            id: 'lesson-5-1',
            title: 'Adam (AS), le premier homme',
            content: 'L\'histoire d\'Adam, le premier homme et prophète...',
            orderIndex: 0,
            durationMinutes: 20,
          ),
          Lesson(
            id: 'lesson-5-2',
            title: 'Nouh (AS) et le déluge',
            content: 'Découvrons l\'histoire du prophète Nouh et du grand déluge...',
            orderIndex: 1,
            durationMinutes: 25,
          ),
          Lesson(
            id: 'lesson-5-3',
            title: 'Ibrahim (AS), l\'ami d\'Allah',
            content: 'L\'histoire d\'Ibrahim, celui qui a construit la Kaaba...',
            orderIndex: 2,
            durationMinutes: 20,
          ),
        ],
        quiz: Quiz(
          id: 'quiz-5',
          title: 'Quiz sur les prophètes',
          description: 'Testez vos connaissances sur l\'histoire des prophètes.',
          questions: [
            QuizQuestion(
              id: 'q5-1',
              question: 'Qui a construit l\'arche sur ordre d\'Allah ?',
              options: ['Ibrahim (AS)', 'Nouh (AS)', 'Moussa (AS)', 'Souleyman (AS)'],
              correctOptionIndex: 1,
            ),
            QuizQuestion(
              id: 'q5-2',
              question: 'Quel prophète est connu pour avoir reçu les Tables de la Loi (Tawrat) ?',
              options: ['Ibrahim (AS)', 'Issa (AS)', 'Moussa (AS)', 'Daoud (AS)'],
              correctOptionIndex: 2,
            ),
            QuizQuestion(
              id: 'q5-3',
              question: 'Qui était le père d\'Ismaïl et d\'Ishaq ?',
              options: ['Adam (AS)', 'Ibrahim (AS)', 'Yacoub (AS)', 'Souleyman (AS)'],
              correctOptionIndex: 1,
            ),
          ],
        ),
      ),
      Course(
        id: 'course-6',
        title: 'Les piliers de l\'Islam',
        description: 'Étude approfondie des cinq piliers fondamentaux de l\'Islam.',
        categoryId: 'cat-3',
        level: 'intermediate',
        imageUrl: 'assets/images/pillars.jpg',
        videoUrl: 'https://example.com/video6.mp4',
        pdfUrl: 'assets/pdf/pillars_of_islam.pdf',
        durationMinutes: 70,
        lessons: [
          Lesson(
            id: 'lesson-6-1',
            title: 'La Shahada (témoignage de foi)',
            content: 'Le premier pilier : la déclaration de foi en l\'unicité d\'Allah...',
            orderIndex: 0,
            durationMinutes: 15,
          ),
          Lesson(
            id: 'lesson-6-2',
            title: 'La Salat (prière)',
            content: 'Le deuxième pilier : la prière rituelle cinq fois par jour...',
            orderIndex: 1,
            durationMinutes: 15,
          ),
          Lesson(
            id: 'lesson-6-3',
            title: 'La Zakat (aumône)',
            content: 'Le troisième pilier : l\'aumône obligatoire aux nécessiteux...',
            orderIndex: 2,
            durationMinutes: 15,
          ),
          Lesson(
            id: 'lesson-6-4',
            title: 'Le Sawm (jeûne du Ramadan)',
            content: 'Le quatrième pilier : le jeûne du mois sacré de Ramadan...',
            orderIndex: 3,
            durationMinutes: 15,
          ),
          Lesson(
            id: 'lesson-6-5',
            title: 'Le Hajj (pèlerinage)',
            content: 'Le cinquième pilier : le pèlerinage à la Mecque...',
            orderIndex: 4,
            durationMinutes: 10,
          ),
        ],
        quiz: Quiz(
          id: 'quiz-6',
          title: 'Quiz sur les piliers de l\'Islam',
          description: 'Testez vos connaissances sur les cinq piliers fondamentaux.',
          questions: [
            QuizQuestion(
              id: 'q6-1',
              question: 'Combien de fois par jour un musulman doit-il prier ?',
              options: ['3', '4', '5', '6'],
              correctOptionIndex: 2,
            ),
            QuizQuestion(
              id: 'q6-2',
              question: 'La Zakat doit être donnée à hauteur de quel pourcentage de la richesse ?',
              options: ['1%', '2,5%', '5%', '10%'],
              correctOptionIndex: 1,
            ),
            QuizQuestion(
              id: 'q6-3',
              question: 'Le Hajj doit être accompli au moins :',
              options: [
                'Une fois par an',
                'Une fois dans la vie si on en a les moyens',
                'Deux fois dans la vie',
                'À chaque fois qu\'on visite l\'Arabie Saoudite'
              ],
              correctOptionIndex: 1,
            ),
          ],
        ),
      ),
    ]);
  }

  // Initialisation des utilisateurs
  void _initUsers() {
    _users.addAll([
      User(
        id: 'user-1',
        name: 'Ahmed Benali',
        email: 'ahmed@example.com',
        role: 'student',
        profileImageUrl: 'assets/images/user1.jpg',
        completedCourseIds: ['course-1', 'course-3'],
        quizScores: {
          'quiz-1': 85,
          'quiz-3': 70,
        },
      ),
      User(
        id: 'user-2',
        name: 'Fatima Zahra',
        email: 'fatima@example.com',
        role: 'student',
        profileImageUrl: 'assets/images/user2.jpg',
        completedCourseIds: ['course-1', 'course-2', 'course-5'],
        quizScores: {
          'quiz-1': 90,
          'quiz-2': 85,
          'quiz-5': 95,
        },
      ),
      User(
        id: 'user-3',
        name: 'Mohammed Chakir',
        email: 'mohammed@example.com',
        role: 'parent',
        profileImageUrl: 'assets/images/user3.jpg',
        completedCourseIds: [],
        quizScores: {},
      ),
    ]);
  }

  // Méthodes d'accès aux données

  // Recherche d'un utilisateur par email
  User? findUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
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
        final course = _courses.firstWhere(
              (course) => course.quiz.id == quizId,
          orElse: () => null as Course,
        );

        if (course != null) {
          final completedCourses = List<String>.from(user.completedCourseIds);
          if (!completedCourses.contains(course.id)) {
            completedCourses.add(course.id);
            _users[userIndex] = user.copyWith(completedCourseIds: completedCourses);
          }
        }
      }
    }
  }
}