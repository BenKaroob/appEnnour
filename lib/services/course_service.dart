import 'dart:async';
import '../models/index.dart';
import 'mock_data_service.dart';

// Service pour gérer les cours et les catégories
class CourseService {
  final MockDataService _mockDataService = MockDataService();

  // Singleton pattern
  static final CourseService _instance = CourseService._internal();
  factory CourseService() => _instance;
  CourseService._internal();

  // Récupère toutes les catégories
  Future<List<Category>> getCategories() async {
    // Simuler un délai de réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDataService.categories;
  }

  // Récupère une catégorie par son ID
  Future<Category?> getCategoryById(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDataService.findCategoryById(categoryId);
  }

  // Récupère tous les cours
  Future<List<Course>> getAllCourses() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _mockDataService.courses;
  }

  // Récupère les cours d'une catégorie spécifique
  Future<List<Course>> getCoursesByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockDataService.getCoursesByCategory(categoryId);
  }

  // Récupère un cours par son ID
  Future<Course?> getCourseById(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockDataService.findCourseById(courseId);
  }

  // Récupère le quiz associé à un cours
  Future<Quiz?> getQuizForCourse(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final course = await getCourseById(courseId);
    return course?.quiz;
  }

// TODO: Implémenter les appels API réels lorsque le backend sera prêt
// Future<List<Category>> fetchCategoriesFromApi() async {
//   // Implémentation future avec http package
//   return [];
// }
}