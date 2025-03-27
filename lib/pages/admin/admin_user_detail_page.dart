import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../utils/app_constants.dart';
import '../../widgets/admin/loading_indicator.dart';
import '../../widgets/custom_app_bar.dart';
import 'admin_user_form_page.dart';

class AdminUserDetailPage extends StatefulWidget {
  static const String routeName = '/admin/users/detail';
  final String userId;

  const AdminUserDetailPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  final UserService _userService = UserService();
  late Future<User> _userFuture;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _userFuture = _userService.getUserById(widget.userId);
    });

    try {
      final user = await _userFuture;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du chargement de l\'utilisateur: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _navigateToEditUser() async {
    if (_user == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserFormPage(user: _user),
      ),
    );

    if (result == true && mounted) {
      _loadUser();
    }
  }

  void _showDeleteConfirmationDialog() {
    if (_user == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cet utilisateur : ${_user!.firstName} ${_user!.lastName} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    if (_user == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _userService.deleteUser(_user!.id);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'utilisateur a été supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Retourne true pour indiquer que l'utilisateur a été supprimé
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de la suppression: $e');
    }
  }

  Future<void> _toggleUserStatus() async {
    if (_user == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final updatedUser = await _userService.updateUserStatus(
        _user!.id,
        !_user!.isActive,
      );

      setState(() {
        _user = updatedUser;
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le statut de l\'utilisateur a été modifié en ${_user!.isActive ? 'Actif' : 'Inactif'}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de la modification du statut: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Détails de l\'utilisateur',
        showBackButton: true,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _user == null
          ? const Center(
        child: Text('Utilisateur non trouvé'),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Actions rapides
            _buildActionButtons(),
            const SizedBox(height: 24),

            // Informations utilisateur
            _buildUserHeader(),
            const SizedBox(height: 24),

            // Détails personnels
            _buildSectionTitle('Informations personnelles'),
            _buildInfoCard(_buildPersonalInfo()),
            const SizedBox(height: 16),

            // Coordonnées
            _buildSectionTitle('Coordonnées'),
            _buildInfoCard(_buildContactInfo()),
            const SizedBox(height: 16),

            // Informations d'accès
            _buildSectionTitle('Informations d\'accès'),
            _buildInfoCard(_buildAccessInfo()),
            const SizedBox(height: 16),

            // Progression (pour les étudiants)
            if (_user!.role.toLowerCase() == 'étudiant') ...[
              _buildSectionTitle('Progression'),
              _buildInfoCard(_buildProgressInfo()),
              const SizedBox(height: 16),
            ],

            // Enfants (pour les parents)
            if (_user!.role.toLowerCase() == 'parent' &&
                _user!.childrenIds != null &&
                _user!.childrenIds!.isNotEmpty) ...[
              _buildSectionTitle('Enfants'),
              _buildInfoCard(_buildChildrenInfo()),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bouton pour changer le statut
        OutlinedButton.icon(
          onPressed: _toggleUserStatus,
          icon: Icon(
            _user!.isActive ? Icons.cancel : Icons.check_circle,
            color: _user!.isActive ? Colors.red : Colors.green,
          ),
          label: Text(
            _user!.isActive ? 'Désactiver' : 'Activer',
            style: TextStyle(
              color: _user!.isActive ? Colors.red : Colors.green,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _user!.isActive ? Colors.red : Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton d'édition
        ElevatedButton.icon(
          onPressed: _navigateToEditUser,
          icon: const Icon(Icons.edit),
          label: const Text('Modifier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        // Bouton de suppression
        ElevatedButton.icon(
          onPressed: _showDeleteConfirmationDialog,
          icon: const Icon(Icons.delete),
          label: const Text('Supprimer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar de l'utilisateur
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: _user!.profileImageUrl != null && _user!.profileImageUrl!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              _user!.profileImageUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                );
              },
            ),
          )
              : Icon(
            Icons.person,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 20),
        // Informations de base
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_user!.firstName} ${_user!.lastName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRoleChip(),
                  const SizedBox(width: 8),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _user!.email,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (_user!.phone != null && _user!.phone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _user!.phone!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip() {
    Color chipColor;
    IconData iconData;

    switch (_user!.role.toLowerCase()) {
      case 'étudiant':
        chipColor = Colors.blue;
        iconData = Icons.school;
        break;
      case 'parent':
        chipColor = Colors.green;
        iconData = Icons.family_restroom;
        break;
      case 'professeur':
        chipColor = Colors.purple;
        iconData = Icons.menu_book;
        break;
      default:
        chipColor = Colors.grey;
        iconData = Icons.person;
    }

    return Chip(
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.5)),
      avatar: Icon(iconData, size: 16, color: chipColor),
      label: Text(
        _user!.role,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      backgroundColor: _user!.isActive
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      side: BorderSide(
        color: _user!.isActive
            ? Colors.green.withOpacity(0.5)
            : Colors.red.withOpacity(0.5),
      ),
      avatar: Icon(
        _user!.isActive ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: _user!.isActive ? Colors.green : Colors.red,
      ),
      label: Text(
        _user!.isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          color: _user!.isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Prénom', _user!.firstName),
        _buildInfoRow('Nom', _user!.lastName),
        if (_user!.birthDate != null)
          _buildInfoRow('Date de naissance', _formatDate(_user!.birthDate!)),
        if (_user!.gender != null && _user!.gender!.isNotEmpty)
          _buildInfoRow('Genre', _user!.gender!),
        if (_user!.nationality != null && _user!.nationality!.isNotEmpty)
          _buildInfoRow('Nationalité', _user!.nationality!),
        if (_user!.address != null && _user!.address!.isNotEmpty)
          _buildInfoRow('Adresse', _user!.address!),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Email', _user!.email),
        if (_user!.phone != null && _user!.phone!.isNotEmpty)
          _buildInfoRow('Téléphone', _user!.phone!),
        if (_user!.emergencyContact != null && _user!.emergencyContact!.isNotEmpty)
          _buildInfoRow('Contact d\'urgence', _user!.emergencyContact!),
      ],
    );
  }

  Widget _buildAccessInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Nom d\'utilisateur', _user!.username),
        _buildInfoRow('Statut', _user!.isActive ? 'Actif' : 'Inactif'),
        if (_user!.creationDate != null)
          _buildInfoRow('Date de création', _formatDate(_user!.creationDate!)),
        if (_user!.lastLoginDate != null)
          _buildInfoRow('Dernière connexion', _formatDate(_user!.lastLoginDate!)),
      ],
    );
  }

  Widget _buildProgressInfo() {
    // Pour un vrai projet, ces données viendraient d'un service
    final completedCourses = _user!.completedCourses ?? [];
    final inProgressCourses = _user!.inProgressCourses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Cours terminés', '${completedCourses.length}'),
        _buildInfoRow('Cours en cours', '${inProgressCourses.length}'),
        if (completedCourses.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Cours terminés:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Liste des cours terminés (simulée)
          for (int i = 0; i < completedCourses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text('Cours ${completedCourses[i]}'),
                ],
              ),
            ),
        ],
        if (inProgressCourses.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Cours en cours:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Liste des cours en cours (simulée)
          for (int i = 0; i < inProgressCourses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.pending, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Text('Cours ${inProgressCourses[i]}'),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildChildrenInfo() {
    // Pour un vrai projet, ces données viendraient d'un service
    final childrenIds = _user!.childrenIds ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Nombre d\'enfants', '${childrenIds.length}'),
        const SizedBox(height: 12),
        const Text(
          'Liste des enfants:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Liste des enfants (simulée)
        for (int i = 0; i < childrenIds.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text('Enfant ${i + 1}'),
              subtitle: Text('ID: ${childrenIds[i]}'),
              trailing: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  // Naviguer vers les détails de l'enfant
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminUserDetailPage(userId: childrenIds[i]),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}