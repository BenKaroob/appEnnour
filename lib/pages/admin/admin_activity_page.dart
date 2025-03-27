import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../../utils/index.dart';

class AdminActivityPage extends StatefulWidget {
  const AdminActivityPage({Key? key}) : super(key: key);

  @override
  State<AdminActivityPage> createState() => _AdminActivityPageState();
}

class _AdminActivityPageState extends State<AdminActivityPage> {
  final ActivityLogService _activityLogService = ActivityLogService();
  final AdminAuthService _authService = AdminAuthService();

  bool _isLoading = true;
  List<ActivityLog> _activities = [];
  String? _errorMessage;

  // Filter states
  String _searchQuery = '';
  String? _selectedAction;
  String? _selectedTargetType;
  String? _selectedAdminId;
  DateTime? _startDate;
  DateTime? _endDate;

  // Lists for filter dropdowns
  List<String> _actionTypes = [];
  List<String> _targetTypes = [];
  List<Admin> _admins = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Load activity logs
  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check permissions
      final admin = _authService.currentAdmin;
      if (admin == null || (!admin.hasPermission('read:all') && !admin.hasPermission('read:logs'))) {
        setState(() {
          _errorMessage = 'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.';
          _isLoading = false;
        });
        return;
      }

      // Load activities
      final activities = await _activityLogService.getAllActivityLogs();

      // Load admins for filter
      final admins = await _authService.getAllAdmins();

      // Extract unique action types and target types
      final actionTypes = <String>{};
      final targetTypes = <String>{};

      for (final activity in activities) {
        actionTypes.add(activity.action);
        targetTypes.add(activity.targetType);
      }

      setState(() {
        _activities = activities;
        _admins = admins;
        _actionTypes = actionTypes.toList()..sort();
        _targetTypes = targetTypes.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des activités: $e';
        _isLoading = false;
      });
      print('Erreur de chargement des activités: $e');
    }
  }

  // Get filtered activities
  List<ActivityLog> _getFilteredActivities() {
    return _activities.where((activity) {
      // Filter by text search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final descriptionMatch = activity.description.toLowerCase().contains(query);
        final adminNameMatch = activity.adminName.toLowerCase().contains(query);
        final targetTypeMatch = activity.displayTargetType.toLowerCase().contains(query);
        final targetIdMatch = activity.targetId != null && activity.targetId!.toLowerCase().contains(query);

        if (!descriptionMatch && !adminNameMatch && !targetTypeMatch && !targetIdMatch) {
          return false;
        }
      }

      // Filter by action type
      if (_selectedAction != null && _selectedAction!.isNotEmpty) {
        if (activity.action != _selectedAction) {
          return false;
        }
      }

      // Filter by target type
      if (_selectedTargetType != null && _selectedTargetType!.isNotEmpty) {
        if (activity.targetType != _selectedTargetType) {
          return false;
        }
      }

      // Filter by admin
      if (_selectedAdminId != null && _selectedAdminId!.isNotEmpty) {
        if (activity.adminId != _selectedAdminId) {
          return false;
        }
      }

      // Filter by date range
      if (_startDate != null) {
        if (activity.timestamp.isBefore(_startDate!)) {
          return false;
        }
      }

      if (_endDate != null) {
        // Add one day to include the end date fully
        final dayAfterEndDate = _endDate!.add(const Duration(days: 1));
        if (activity.timestamp.isAfter(dayAfterEndDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedAction = null;
      _selectedTargetType = null;
      _selectedAdminId = null;
      _startDate = null;
      _endDate = null;
    });
  }

  // Show activity details dialog
  void _showActivityDetails(ActivityLog activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(int.parse(activity.actionColor.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                activity.actionIcon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Détails de l\'activité',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Description
              const Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(activity.description),
              const SizedBox(height: 12),

              // Date and time
              const Text(
                'Date et heure:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_formatDateTime(activity.timestamp)),
              const SizedBox(height: 12),

              // Admin
              const Text(
                'Administrateur:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(activity.adminName),
              const SizedBox(height: 12),

              // Action
              const Text(
                'Action:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(int.parse(activity.actionColor.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getActionDisplayName(activity.action),
                      style: TextStyle(
                        color: Color(int.parse(activity.actionColor.substring(1, 7), radix: 16) + 0xFF000000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Target type
              const Text(
                'Type de cible:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(activity.displayTargetType),
              const SizedBox(height: 12),

              // Target ID
              if (activity.targetId != null) ...[
                const Text(
                  'ID de la cible:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity.targetId!),
                const SizedBox(height: 12),
              ],

              // Details
              if (activity.details != null && activity.details!.isNotEmpty) ...[
                const Text(
                  'Détails supplémentaires:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: activity.details!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Format date time for display
  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm:ss').format(date);
  }

  // Get action display name
  String _getActionDisplayName(String action) {
    switch (action) {
      case 'create': return 'Création';
      case 'update': return 'Modification';
      case 'delete': return 'Suppression';
      case 'login': return 'Connexion';
      case 'logout': return 'Déconnexion';
      default: return action;
    }
  }

  // Select date range
  Future<void> _selectDateRange() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _endDate ?? DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
    }
  }

  // Build activity list
  Widget _buildActivityList() {
    final filteredActivities = _getFilteredActivities();

    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedAction != null ||
                  _selectedTargetType != null || _selectedAdminId != null ||
                  _startDate != null || _endDate != null
                  ? 'Aucune activité ne correspond à vos critères de filtrage.'
                  : 'Aucune activité n\'est disponible actuellement.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _selectedAction != null ||
                _selectedTargetType != null || _selectedAdminId != null ||
                _startDate != null || _endDate != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resetFilters,
                child: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        final activity = filteredActivities[index];
        final actionColor = Color(int.parse(activity.actionColor.substring(1, 7), radix: 16) + 0xFF000000);

        // Group activities by date
        final bool showDateHeader = index == 0 ||
            !_isSameDay(filteredActivities[index].timestamp, filteredActivities[index - 1].timestamp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            if (showDateHeader) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  _formatDateHeader(activity.timestamp),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
            ],

            // Activity item
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    activity.actionIcon,
                    style: TextStyle(
                      fontSize: 18,
                      color: actionColor,
                    ),
                  ),
                ),
              ),
              title: Text(
                activity.description,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: actionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getActionDisplayName(activity.action),
                          style: TextStyle(
                            fontSize: 12,
                            color: actionColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity.displayTargetType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.adminName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(activity.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showActivityDetails(activity),
            ),

            const Divider(
              height: 1,
              indent: 72,
            ),
          ],
        );
      },
    );
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Format date header
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (_isSameDay(date, now)) {
      return 'Aujourd\'hui';
    } else if (_isSameDay(date, yesterday)) {
      return 'Hier';
    } else {
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    }
  }

  // Format time for display
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal d\'activités'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
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
              onPressed: _loadActivities,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Filter section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans les activités...',
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

                // Filter row 1: Action & Target Type
                Row(
                  children: [
                    // Action type filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Action',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: _selectedAction,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Toutes'),
                          ),
                          ..._actionTypes.map((action) {
                            return DropdownMenuItem<String>(
                              value: action,
                              child: Text(_getActionDisplayName(action)),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAction = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Target type filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Type de cible',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: _selectedTargetType,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous'),
                          ),
                          ..._targetTypes.map((type) {
                            final displayType = ActivityLog(
                              id: '',
                              adminId: '',
                              adminName: '',
                              action: '',
                              targetType: type,
                              description: '',
                              timestamp: DateTime.now(),
                            ).displayTargetType;

                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(displayType),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTargetType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter row 2: Admin & Date Range
                Row(
                  children: [
                    // Admin filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Administrateur',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: _selectedAdminId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous'),
                          ),
                          ..._admins.map((admin) {
                            return DropdownMenuItem<String>(
                              value: admin.id,
                              child: Text(admin.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAdminId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Date range filter
                    Expanded(
                      child: InkWell(
                        onTap: _selectDateRange,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Période',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _startDate != null && _endDate != null
                                ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                : 'Toutes dates',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Filter actions
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${_getFilteredActivities().length} activité(s)',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.filter_alt_off),
                        label: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Activity list
          Expanded(
            child: _buildActivityList(),
          ),
        ],
      ),
    );
  }
}