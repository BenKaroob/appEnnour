import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import '../../pages/admin/admin_dashboard_page.dart';
import '../../pages/admin/admin_users_page.dart';
import '../../pages/admin/admin_course_page.dart';
import '../../pages/admin/admin_quizzes_page.dart';
import '../../pages/admin/admin_categories_page.dart';
import '../../pages/admin/admin_activity_page.dart';
import '../../pages/admin/admin_statistics_page.dart';
import '../../pages/admin/admin_admins_page.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminAuthService authService = AdminAuthService();
    final admin = authService.currentAdmin;

    if (admin == null) {
      return const Drawer(
        child: Center(
          child: Text('Non connecté'),
        ),
      );
    }

    return Drawer(
      child: Column(
        children: [
          // En-tête du drawer avec info admin
          UserAccountsDrawerHeader(
            accountName: Text(admin.name),
            accountEmail: Text(admin.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                admin.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
          ),

          // Liste des éléments du menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  title: 'Tableau de bord',
                  icon: Icons.dashboard,
                  route: '/',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardPage(),
                      ),
                    );
                  },
                ),
                if (admin.hasPermission('read:course'))
                  _buildDrawerItem(
                    context,
                    title: 'Cours',
                    icon: Icons.book,
                    route: '/admin/courses',
                    onTap: () {
                      if (currentRoute != '/admin/courses') {
                        // Éviter l'erreur AdminCoursePage en naviguant vers la page de formulaire
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminCourseFormPage(isEditing: false),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                if (admin.hasPermission('read:course'))
                  _buildDrawerItem(
                    context,
                    title: 'Quiz',
                    icon: Icons.quiz,
                    route: '/admin/quizzes',
                    onTap: () {
                      if (currentRoute != '/admin/quizzes') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminQuizzesPage(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                if (admin.hasPermission('read:user'))
                  _buildDrawerItem(
                    context,
                    title: 'Utilisateurs',
                    icon: Icons.people,
                    route: '/admin/users',
                    onTap: () {
                      if (currentRoute != '/admin/users') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminUsersPage(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                if (admin.hasPermission('read:category'))
                  _buildDrawerItem(
                    context,
                    title: 'Catégories',
                    icon: Icons.category,
                    route: '/admin/categories',
                    onTap: () {
                      if (currentRoute != '/admin/categories') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminCategoriesPage(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                _buildDrawerItem(
                  context,
                  title: 'Activités',
                  icon: Icons.history,
                  route: '/admin/activities',
                  onTap: () {
                    if (currentRoute != '/admin/activities') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminActivityPage(),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                if (admin.hasPermission('read:stats'))
                  _buildDrawerItem(
                    context,
                    title: 'Statistiques',
                    icon: Icons.analytics,
                    route: '/admin/statistics',
                    onTap: () {
                      if (currentRoute != '/admin/statistics') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminStatisticsPage(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                if (admin.role == 'super_admin')
                  _buildDrawerItem(
                    context,
                    title: 'Administrateurs',
                    icon: Icons.admin_panel_settings,
                    route: '/admin/admins',
                    onTap: () {
                      if (currentRoute != '/admin/admins') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminAdminsPage(),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  title: 'Déconnexion',
                  icon: Icons.logout,
                  route: '',
                  onTap: () async {
                    final bool confirm = await AppUtils.showConfirmDialog(
                      context,
                      title: 'Déconnexion',
                      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
                      confirmText: 'Déconnexion',
                      cancelText: 'Annuler',
                    );

                    if (confirm) {
                      await authService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/admin/login');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required String route,
        required VoidCallback onTap,
      }) {
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }
}