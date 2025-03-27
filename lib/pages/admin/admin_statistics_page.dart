import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import 'dart:math' as math;

class AdminStatisticsPage extends StatefulWidget {
  const AdminStatisticsPage({Key? key}) : super(key: key);

  @override
  State<AdminStatisticsPage> createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage> {
  final AdminAuthService _authService = AdminAuthService();
  final AdminCourseService _courseService = AdminCourseService();
  final AdminUserService _userService = AdminUserService();

  bool _isLoading = true;
  String? _errorMessage;

  // Statistics data
  Map<String, dynamic> _generalStats = {};
  Map<String, dynamic> _userStats = {};
  Map<String, dynamic> _courseStats = {};
  Map<String, dynamic> _activityStats = {};

  // Time range
  String _selectedTimeRange = 'all';
  final List<String> _timeRanges = ['week', 'month', 'year', 'all'];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // Load all statistics data
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check permissions
      final admin = _authService.currentAdmin;
      if (admin == null || (!admin.hasPermission('read:stats') && !admin.hasPermission('read:all'))) {
        setState(() {
          _errorMessage = 'Vous n\'avez pas les permissions nécessaires pour accéder à ces statistiques.';
          _isLoading = false;
        });
        return;
      }

      // Load statistics based on time range
      final generalStats = await _courseService.getGeneralStatistics(_selectedTimeRange);
      final userStats = await _userService.getUserStatistics(_selectedTimeRange);
      final courseStats = await _courseService.getCourseStatistics(_selectedTimeRange);
      final activityStats = await _userService.getActivityStatistics(_selectedTimeRange);

      setState(() {
        _generalStats = generalStats;
        _userStats = userStats;
        _courseStats = courseStats;
        _activityStats = activityStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des statistiques: $e';
        _isLoading = false;
      });
      print('Erreur de chargement des statistiques: $e');
    }
  }

  // Handle time range change
  void _handleTimeRangeChange(String? value) {
    if (value != null && value != _selectedTimeRange) {
      setState(() {
        _selectedTimeRange = value;
      });
      _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
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
              onPressed: _loadStatistics,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _buildStatisticsContent(),
    );
  }

  Widget _buildStatisticsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time range selector
          _buildTimeRangeSelector(),
          const SizedBox(height: 24),

          // General statistics
          _buildSectionTitle('Vue d\'ensemble'),
          _buildGeneralStatsCards(),
          const SizedBox(height: 24),

          // User statistics
          _buildSectionTitle('Statistiques des utilisateurs'),
          _buildUserStatsCards(),
          const SizedBox(height: 24),

          // Course statistics
          _buildSectionTitle('Statistiques des cours'),
          _buildCourseStatsCards(),
          const SizedBox(height: 24),

          // Most active users chart
          _buildSectionTitle('Utilisateurs les plus actifs'),
          _buildActiveUsersChart(),
          const SizedBox(height: 24),

          // Most popular courses chart
          _buildSectionTitle('Cours les plus populaires'),
          _buildPopularCoursesChart(),
          const SizedBox(height: 24),

          // Completion rate chart
          _buildSectionTitle('Taux de complétion des cours'),
          _buildCompletionRateChart(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Time range selector widget
  Widget _buildTimeRangeSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              'Période:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedTimeRange,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'week',
                    child: Text('Dernière semaine'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'month',
                    child: Text('Dernier mois'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'year',
                    child: Text('Dernière année'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'all',
                    child: Text('Tout le temps'),
                  ),
                ],
                onChanged: _handleTimeRangeChange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // General statistics cards
  Widget _buildGeneralStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Utilisateurs',
          value: _generalStats['totalUsers']?.toString() ?? '0',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Cours',
          value: _generalStats['totalCourses']?.toString() ?? '0',
          icon: Icons.book,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Leçons complétées',
          value: _generalStats['completedLessons']?.toString() ?? '0',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Quiz passés',
          value: _generalStats['quizzesTaken']?.toString() ?? '0',
          icon: Icons.quiz,
          color: Colors.purple,
        ),
      ],
    );
  }

  // User statistics cards
  Widget _buildUserStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Élèves',
          value: _userStats['studentCount']?.toString() ?? '0',
          icon: Icons.school,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Parents',
          value: _userStats['parentCount']?.toString() ?? '0',
          icon: Icons.family_restroom,
          color: Colors.teal,
        ),
        _buildStatCard(
          title: 'Score moyen',
          value: (_userStats['averageScore'] != null)
              ? '${(_userStats['averageScore'] as double).toStringAsFixed(1)}%'
              : '0%',
          icon: Icons.analytics,
          color: Colors.amber,
        ),
        _buildStatCard(
          title: 'Utilisateurs actifs',
          value: _userStats['activeUsers']?.toString() ?? '0',
          icon: Icons.person_pin,
          color: Colors.deepPurple,
        ),
      ],
    );
  }

  // Course statistics cards
  Widget _buildCourseStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Taux de complétion',
          value: (_courseStats['completionRate'] != null)
              ? '${(_courseStats['completionRate'] as double).toStringAsFixed(1)}%'
              : '0%',
          icon: Icons.done_all,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Temps moyen',
          value: _courseStats['averageTime'] != null
              ? '${_courseStats['averageTime']} min'
              : '0 min',
          icon: Icons.timer,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Cours débutants',
          value: _courseStats['beginnerCourses']?.toString() ?? '0',
          icon: Icons.child_care,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Cours avancés',
          value: _courseStats['advancedCourses']?.toString() ?? '0',
          icon: Icons.psychology,
          color: Colors.red,
        ),
      ],
    );
  }

  // Statistic card widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Active users chart
  Widget _buildActiveUsersChart() {
    // This would normally be populated from the activityStats data
    // For now, we'll create a mock chart with placeholder data
    final mockActiveUsers = [
      {'name': 'Ahmed B.', 'activity': 85},
      {'name': 'Fatima Z.', 'activity': 78},
      {'name': 'Youssef M.', 'activity': 65},
      {'name': 'Amina K.', 'activity': 60},
      {'name': 'Omar S.', 'activity': 55},
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: mockActiveUsers.length,
                itemBuilder: (context, index) {
                  final user = mockActiveUsers[index];
                  final activity = user['activity'] as int;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: activity / 100,
                                backgroundColor: Colors.grey[200],
                                color: Colors.blue,
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$activity%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Popular courses chart
  Widget _buildPopularCoursesChart() {
    // This would normally be populated from the courseStats data
    // For now, we'll create a mock chart with placeholder data
    final mockPopularCourses = [
      {'title': 'L\'alphabet arabe', 'students': 120},
      {'title': 'Introduction à la récitation', 'students': 95},
      {'title': 'Mémorisation de sourates courtes', 'students': 80},
      {'title': 'Les pronoms personnels', 'students': 65},
      {'title': 'Les piliers de l\'Islam', 'students': 60},
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: mockPopularCourses.length,
                itemBuilder: (context, index) {
                  final course = mockPopularCourses[index];
                  final students = course['students'] as int;
                  final maxStudents = mockPopularCourses[0]['students'] as int;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: students / maxStudents,
                                backgroundColor: Colors.grey[200],
                                color: Colors.orange,
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$students',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Completion rate chart
  Widget _buildCompletionRateChart() {
    // This would normally use real data from courseStats
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRadialProgressIndicator(
                      label: 'Arabe',
                      percentage: 0.68,
                      color: Colors.blue,
                    ),
                    _buildRadialProgressIndicator(
                      label: 'Coran',
                      percentage: 0.72,
                      color: Colors.green,
                    ),
                    _buildRadialProgressIndicator(
                      label: 'Culture',
                      percentage: 0.53,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pourcentage de cours complétés par catégorie',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Radial progress indicator for completion chart
  Widget _buildRadialProgressIndicator({
    required String label,
    required double percentage,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  strokeWidth: 10,
                ),
              ),
              Center(
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}