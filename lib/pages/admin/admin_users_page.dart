import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';
import 'admin_user_form_page.dart';
import 'admin_user_detail_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final AdminUserService _userService = AdminUserService();
  final AdminAuthService _authService = AdminAuthService();

  bool _isLoading = true;
  List<User> _users = [];
  String _searchQuery = '';
  String? _selectedRole;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Chargement des utilisateurs
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifier les permissions
      final admin = _authService.currentAdmin;
      if (admin == null || (!admin.hasPermission('read:all') && !admin.hasPermission('read:user'))) {
        setState(() {
          _errorMessage = 'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.';
          _isLoading = false;
        });
        return;
      }

      // Charger les utilisateurs
      final users = await _userService.getAllUsers();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des utilisateurs: $e';
        _isLoading = false;
      });
      print('Erreur de chargement des utilisateurs: $e');
    }
  }

  // Filtrer les utilisateurs selon les critères
  List<User> _getFilteredUsers() {
    return _users.where((user) {
      // Filtrer par rôle si sélectionné
      if (_selectedRole != null && _selectedRole!.isNotEmpty) {
        if (user.role != _selectedRole) {
          return false;
        }
      }

      // Filtrer par texte de recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatches = user.name.toLowerCase().contains(query);
        final emailMatches = user.email.toLowerCase().contains(query);
        if (!nameMatches && !emailMatches) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Navigation vers le détail d'un utilisateur
  void _navigateToUserDetail(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserDetailPage(userId: user.id),
      ),
    ).then((_) => _loadUsers());
  }

  // Navigation vers la création d'un nouvel utilisateur
  void _navigateToCreateUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminUserFormPage(isEditing: false),
      ),
    ).then((_) => _loadUsers());
  }

  // Suppression d'un utilisateur
  Future<void> _deleteUser(User user) async {
    // Confirmation de suppression
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Confirmation de suppression',
      message: 'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.name}" ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (!confirm) return;

    try {
      final success = await _userService.deleteUser(user.id);

      if (success) {
        // Afficher un message de succès
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'L\'utilisateur "${user.name}" a été supprimé avec succès.',
            backgroundColor: Colors.green,
          );
        }

        // Recharger les utilisateurs
        _loadUsers();
      } else {
        // Afficher un message d'erreur
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Échec de la suppression de l\'utilisateur.',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      // Afficher un message d'erreur
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Réinitialisation du mot de passe d'un utilisateur
  Future<void> _resetUserPassword(User user) async {
    // Confirmation de réinitialisation
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Confirmation de réinitialisation',
      message: 'Êtes-vous sûr de vouloir réinitialiser le mot de passe de l\'utilisateur "${user.name}" ?',
      confirmText: 'Réinitialiser',
      cancelText: 'Annuler',
    );

    if (!confirm) return;

    try {
      final success = await _userService.resetUserPassword(user.id);

      if (success) {
        // Afficher un message de succès
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Le mot de passe de l\'utilisateur "${user.name}" a été réinitialisé avec succès.',
            backgroundColor: Colors.green,
          );
        }
      } else {
        // Afficher un message d'erreur
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'Échec de la réinitialisation du mot de passe.',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      // Afficher un message d'erreur
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Construction de la liste des utilisateurs filtrés
  Widget _buildUsersList() {
    final filteredUsers = _getFilteredUsers();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedRole != null
                  ? 'Aucun utilisateur ne correspond à vos critères de recherche.'
                  : 'Aucun utilisateur n\'est disponible actuellement.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _selectedRole != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedRole = null;
                  });
                },
                child: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];

        // Icône de rôle
        IconData roleIcon;
        String roleText;
        Color roleColor;

        if (user.role == 'student') {
          roleIcon = Icons.school;
          roleText = 'Élève';
          roleColor = Colors.blue;
        } else {
          roleIcon = Icons.people;
          roleText = 'Parent';
          roleColor = Colors.purple;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: AppUtils.getColorFromText(user.name),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(user.email),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            roleIcon,
                            size: 12,
                            color: roleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            roleText,
                            style: TextStyle(
                              fontSize: 12,
                              color: roleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user.completedCourseIds.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.book,
                              size: 12,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.completedCourseIds.length} cours',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                switch (value) {
                  case 'view':
                    _navigateToUserDetail(user);
                    break;
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminUserFormPage(
                          isEditing: true,
                          user: user,
                        ),
                      ),
                    ).then((_) => _loadUsers());
                    break;
                  case 'reset_password':
                    await _resetUserPassword(user);
                    break;
                  case 'delete':
                    await _deleteUser(user);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Voir les détails'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                if (_authService.currentAdmin?.hasPermission('update:user') == true)
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Modifier'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                if (_authService.currentAdmin?.hasPermission('update:user') == true)
                  const PopupMenuItem<String>(
                    value: 'reset_password',
                    child: ListTile(
                      leading: Icon(Icons.password),
                      title: Text('Réinitialiser le mot de passe'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                if (_authService.currentAdmin?.hasPermission('delete:user') == true)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
              ],
            ),
            onTap: () => _navigateToUserDetail(user),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCreateUser = _authService.currentAdmin?.hasPermission('create:user') == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
              onPressed: _loadUsers,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Filtres et barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Filtre par rôle
                Row(
                  children: [
                    const Text(
                      'Rôle:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: _selectedRole,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous les rôles'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'student',
                            child: Text('Élèves'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'parent',
                            child: Text('Parents'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Informations
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Total: ${_getFilteredUsers().length} utilisateur(s)',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des utilisateurs
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
      // Bouton d'ajout d'utilisateur
      floatingActionButton: canCreateUser
          ? FloatingActionButton(
        onPressed: _navigateToCreateUser,
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}