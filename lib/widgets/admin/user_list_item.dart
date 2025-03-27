import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_constants.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserListItem({
    Key? key,
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar de l'utilisateur
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        user.profileImageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.person,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Informations de l'utilisateur
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.name} ${user.email}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        // Row(
                        //   children: [
                        //     _buildRoleChip(context, user.role),
                        //     const SizedBox(width: 8),
                        //     _buildStatusChip(context, user.isActive),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  // Actions
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                ],
              ),
              // Informations supplémentaires
              // if (user.lastLoginDate != null) ...[
              //   const SizedBox(height: 12),
              //   Row(
              //     children: [
              //       const Icon(Icons.access_time, size: 16, color: Colors.grey),
              //       const SizedBox(width: 4),
              //       Text(
              //         'Dernière connexion: ${_formatDate(user.lastLoginDate!)}',
              //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //           color: Colors.grey,
              //         ),
              //       ),
              //     ],
              //   ),
              // ],
              // if (user.creationDate != null) ...[
              //   const SizedBox(height: 4),
              //   Row(
              //     children: [
              //       const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              //       const SizedBox(width: 4),
              //       Text(
              //         'Créé le: ${_formatDate(user.creationDate!)}',
              //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //           color: Colors.grey,
              //         ),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(BuildContext context, String role) {
    Color chipColor;
    IconData iconData;

    switch (role.toLowerCase()) {
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
        role,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    return Chip(
      backgroundColor: isActive
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      side: BorderSide(
        color: isActive
            ? Colors.green.withOpacity(0.5)
            : Colors.red.withOpacity(0.5),
      ),
      avatar: Icon(
        isActive ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: isActive ? Colors.green : Colors.red,
      ),
      label: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}