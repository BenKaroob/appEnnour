import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';

class AdminAdminsPage extends StatefulWidget {
  const AdminAdminsPage({Key? key}) : super(key: key);

  @override
  State<AdminAdminsPage> createState() => _AdminAdminsPageState();
}

class _AdminAdminsPageState extends State<AdminAdminsPage> {
  final AdminAuthService _authService = AdminAuthService();
  final ActivityLogService _activityLogService = ActivityLogService();

  bool _isLoading = true;
  List<Admin> _admins = [];
  String _searchQuery = '';
  String? _selectedRole;
  String? _errorMessage;

  // Available admin roles
  final List<String> _availableRoles = [
    'super_admin',
    'course_admin',
    'content_manager'
  ];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  // Loading admins list
  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if current admin has permission to manage admins
      final currentAdmin = _authService.currentAdmin;
      if (currentAdmin == null || currentAdmin.role != 'super_admin') {
        setState(() {
          _errorMessage = 'Vous n\'avez pas les permissions nécessaires pour gérer les administrateurs.';
          _isLoading = false;
        });
        return;
      }

      // Load admins
      final admins = await _authService.getAllAdmins();

      setState(() {
        _admins = admins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des administrateurs: $e';
        _isLoading = false;
      });
      print('Erreur de chargement des administrateurs: $e');
    }
  }

  // Filter admins based on search query and role
  List<Admin> _getFilteredAdmins() {
    return _admins.where((admin) {
      // Filter by role if selected
      if (_selectedRole != null && _selectedRole!.isNotEmpty) {
        if (admin.role != _selectedRole) {
          return false;
        }
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatches = admin.name.toLowerCase().contains(query);
        final emailMatches = admin.email.toLowerCase().contains(query);
        if (!nameMatches && !emailMatches) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Create new admin
  void _showAddAdminDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'content_manager';
    List<String> selectedPermissions = [];

    // Get permissions based on selected role
    List<String> getDefaultPermissionsForRole(String role) {
      switch (role) {
        case 'super_admin':
          return ['read:all', 'create:all', 'update:all', 'delete:all'];
        case 'course_admin':
          return ['read:course', 'create:course', 'update:course', 'delete:course',
            'read:category', 'create:category', 'update:category', 'delete:category',
            'read:stats'];
        case 'content_manager':
          return ['read:course', 'create:course', 'update:course',
            'read:category', 'read:user', 'read:stats'];
        default:
          return [];
      }
    }

    // Update permissions when role changes
    void updatePermissions(String role) {
      selectedPermissions = getDefaultPermissionsForRole(role);
    }

    // Initialize permissions
    updatePermissions(selectedRole);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter un administrateur'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'email est requis';
                      }
                      if (!value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le mot de passe est requis';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role selection
                  const Text(
                    'Rôle:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _availableRoles.map((role) {
                      String displayRole;
                      switch (role) {
                        case 'super_admin':
                          displayRole = 'Super Administrateur';
                          break;
                        case 'course_admin':
                          displayRole = 'Administrateur de cours';
                          break;
                        case 'content_manager':
                          displayRole = 'Gestionnaire de contenu';
                          break;
                        default:
                          displayRole = role;
                      }

                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(displayRole),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRole = value;
                          updatePermissions(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Permissions section
                  const Text(
                    'Permissions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Les permissions sont définies automatiquement en fonction du rôle.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Show permissions for the selected role
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (String permission in selectedPermissions)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.check, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(permission),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);

                  try {
                    setState(() {
                      _isLoading = true;
                    });

                    // Create new admin
                    final admin = Admin(
                      id: 'admin-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      role: selectedRole,
                      passwordHash: passwordController.text, // In real app, this would be hashed
                      permissions: selectedPermissions,
                      createdAt: DateTime.now(),
                      lastLogin: null,
                    );

                    await _authService.createAdmin(admin);

                    // Log activity
                    await _activityLogService.logActivity(
                      adminId: _authService.currentAdmin!.id,
                      adminName: _authService.currentAdmin!.name,
                      action: 'create',
                      targetType: 'admin',
                      targetId: admin.id,
                      description: 'Création de l\'administrateur ${admin.name}',
                    );

                    // Reload admins
                    _loadAdmins();

                    if (mounted) {
                      AppUtils.showSnackBar(
                        context,
                        'Administrateur créé avec succès',
                        backgroundColor: Colors.green,
                      );
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });

                    if (mounted) {
                      AppUtils.showSnackBar(
                        context,
                        'Erreur lors de la création: $e',
                        backgroundColor: Colors.red,
                      );
                    }
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  // Delete admin
  Future<void> _deleteAdmin(Admin admin) async {
    // Cannot delete yourself
    if (admin.id == _authService.currentAdmin?.id) {
      AppUtils.showSnackBar(
        context,
        'Vous ne pouvez pas supprimer votre propre compte.',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Confirmation dialog
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Confirmation de suppression',
      message: 'Êtes-vous sûr de vouloir supprimer l\'administrateur "${admin.name}" ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (!confirm) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Delete admin
      await _authService.deleteAdmin(admin.id);

      // Log activity
      await _activityLogService.logActivity(
        adminId: _authService.currentAdmin!.id,
        adminName: _authService.currentAdmin!.name,
        action: 'delete',
        targetType: 'admin',
        targetId: admin.id,
        description: 'Suppression de l\'administrateur ${admin.name}',
      );

      // Reload admins
      _loadAdmins();

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Administrateur supprimé avec succès',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la suppression: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Reset admin password
  Future<void> _resetAdminPassword(Admin admin) async {
    final passwordController = TextEditingController();

    // Show dialog to enter new password
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réinitialiser le mot de passe de ${admin.name}'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Nouveau mot de passe',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le mot de passe doit contenir au moins 6 caractères'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context, passwordController.text);
            },
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Update password
      await _authService.resetAdminPassword(admin.id, result);

      // Log activity
      await _activityLogService.logActivity(
        adminId: _authService.currentAdmin!.id,
        adminName: _authService.currentAdmin!.name,
        action: 'update',
        targetType: 'admin',
        targetId: admin.id,
        description: 'Réinitialisation du mot de passe de ${admin.name}',
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Mot de passe réinitialisé avec succès',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la réinitialisation: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Edit admin permissions
  void _editAdminPermissions(Admin admin) {
    // Cannot edit your own permissions
    if (admin.id == _authService.currentAdmin?.id) {
      AppUtils.showSnackBar(
        context,
        'Vous ne pouvez pas modifier vos propres permissions.',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Cannot edit super_admin permissions
    if (admin.role == 'super_admin' && _authService.currentAdmin?.id != admin.id) {
      AppUtils.showSnackBar(
        context,
        'Vous ne pouvez pas modifier les permissions d\'un Super Administrateur.',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Available permission groups
    final permissionGroups = {
      'Cours': ['read:course', 'create:course', 'update:course', 'delete:course'],
      'Catégories': ['read:category', 'create:category', 'update:category', 'delete:category'],
      'Utilisateurs': ['read:user', 'create:user', 'update:user', 'delete:user'],
      'Statistiques': ['read:stats'],
      'Activités': ['read:logs'],
    };

    // Current permissions
    List<String> currentPermissions = List.from(admin.permissions);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Modifier les permissions de ${admin.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rôle: ${admin.displayRole}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Permissions editor
                for (final group in permissionGroups.entries)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: group.value.map((permission) {
                          final isSelected = currentPermissions.contains(permission);

                          return FilterChip(
                            label: Text(_getPermissionDisplayName(permission)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  currentPermissions.add(permission);
                                } else {
                                  currentPermissions.remove(permission);
                                }
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryColor,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  setState(() {
                    _isLoading = true;
                  });

                  // Update admin permissions
                  final updatedAdmin = admin.copyWith(
                    permissions: currentPermissions,
                  );

                  await _authService.updateAdmin(updatedAdmin);

                  // Log activity
                  await _activityLogService.logActivity(
                    adminId: _authService.currentAdmin!.id,
                    adminName: _authService.currentAdmin!.name,
                    action: 'update',
                    targetType: 'admin',
                    targetId: admin.id,
                    description: 'Modification des permissions de ${admin.name}',
                    details: {
                      'permissions': currentPermissions,
                    },
                  );

                  // Reload admins
                  _loadAdmins();

                  if (mounted) {
                    AppUtils.showSnackBar(
                      context,
                      'Permissions mises à jour avec succès',
                      backgroundColor: Colors.green,
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });

                  if (mounted) {
                    AppUtils.showSnackBar(
                      context,
                      'Erreur lors de la mise à jour: $e',
                      backgroundColor: Colors.red,
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // Get human-readable permission name
  String _getPermissionDisplayName(String permission) {
    final parts = permission.split(':');
    if (parts.length != 2) return permission;

    String action = parts[0];
    String resource = parts[1];

    switch (action) {
      case 'read': action = 'Voir'; break;
      case 'create': action = 'Créer'; break;
      case 'update': action = 'Modifier'; break;
      case 'delete': action = 'Supprimer'; break;
      default: break;
    }

    switch (resource) {
      case 'course': resource = 'cours'; break;
      case 'category': resource = 'catégories'; break;
      case 'user': resource = 'utilisateurs'; break;
      case 'stats': resource = 'statistiques'; break;
      case 'logs': resource = 'activités'; break;
      case 'all': resource = 'tout'; break;
      default: break;
    }

    return '$action $resource';
  }

  // Build admin list widget
  Widget _buildAdminsList() {
    final filteredAdmins = _getFilteredAdmins();

    if (filteredAdmins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_accounts,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedRole != null
                  ? 'Aucun administrateur ne correspond à vos critères de recherche.'
                  : 'Aucun administrateur n\'est disponible actuellement.',
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
      itemCount: filteredAdmins.length,
      itemBuilder: (context, index) {
        final admin = filteredAdmins[index];
        final isSelf = admin.id == _authService.currentAdmin?.id;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: admin.role == 'super_admin'
                          ? Colors.amber
                          : admin.role == 'course_admin'
                          ? Colors.blue
                          : AppTheme.primaryColor,
                      radius: 24,
                      child: Icon(
                        admin.role == 'super_admin'
                            ? Icons.shield
                            : admin.role == 'course_admin'
                            ? Icons.school
                            : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  admin.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isSelf)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: const Text(
                                    'Vous',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            admin.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: admin.role == 'super_admin'
                                      ? Colors.amber.withOpacity(0.1)
                                      : admin.role == 'course_admin'
                                      ? Colors.blue.withOpacity(0.1)
                                      : AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  admin.displayRole,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: admin.role == 'super_admin'
                                        ? Colors.amber[800]
                                        : admin.role == 'course_admin'
                                        ? Colors.blue
                                        : AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (admin.lastLogin != null) ...[
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Dernière connexion: ${_formatDate(admin.lastLogin!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Permissions section
                Row(
                  children: [
                    const Icon(
                      Icons.vpn_key,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Permissions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Display permissions
                admin.role == 'super_admin'
                    ? const Text('Accès complet à toutes les fonctionnalités')
                    : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: admin.permissions.map((permission) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPermissionDisplayName(permission),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit permissions
                    TextButton.icon(
                      onPressed: admin.role == 'super_admin' && !isSelf
                          ? null
                          : () => _editAdminPermissions(admin),
                      icon: const Icon(Icons.edit),
                      label: const Text('Permissions'),
                    ),
                    const SizedBox(width: 8),

                    // Reset password
                    TextButton.icon(
                      onPressed: () => _resetAdminPassword(admin),
                      icon: const Icon(Icons.password),
                      label: const Text('Mot de passe'),
                    ),
                    const SizedBox(width: 8),

                    // Delete admin
                    TextButton.icon(
                      onPressed: isSelf || admin.role == 'super_admin'
                          ? null
                          : () => _deleteAdmin(admin),
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
    );
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'il y a ${difference.inMinutes} minute(s)';
      }
      return 'il y a ${difference.inHours} heure(s)';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jour(s)';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des administrateurs'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdmins,
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
              onPressed: _loadAdmins,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un administrateur...',
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

                // Role filter
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
                          ..._availableRoles.map((role) {
                            String displayRole;
                            switch (role) {
                              case 'super_admin':
                                displayRole = 'Super Administrateur';
                                break;
                              case 'course_admin':
                                displayRole = 'Administrateur de cours';
                                break;
                              case 'content_manager':
                                displayRole = 'Gestionnaire de contenu';
                                break;
                              default:
                                displayRole = role;
                            }

                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(displayRole),
                            );
                          }).toList(),
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

                // Admin count
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${_getFilteredAdmins().length} administrateur(s)',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddAdminDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Admin list
          Expanded(
            child: _buildAdminsList(),
          ),
        ],
      ),
    );
  }
}