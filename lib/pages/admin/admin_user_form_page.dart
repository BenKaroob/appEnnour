import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/validators.dart';

class AdminUserFormPage extends StatefulWidget {
  static const String routeName = '/admin/users/form';
  final User? user;
  final bool isEditing;

  const AdminUserFormPage({
    Key? key,
    this.user,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends State<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // Contrôleurs pour les champs du formulaire
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _addressController;
  late TextEditingController _nationalityController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _birthDateController;

  // Variables pour les champs de sélection
  late String _selectedRole;
  late String _selectedGender;
  late bool _isActive;
  DateTime? _birthDate;

  // État du formulaire
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _passwordVisible = false;
  List<String> _availableRoles = ['student', 'parent', 'teacher'];
  List<String> _displayRoles = ['Élève', 'Parent', 'Professeur'];
  List<String> _availableGenders = ['Masculin', 'Féminin', 'Autre'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditing || widget.user != null;

    // Initialiser les contrôleurs avec les valeurs de l'utilisateur si en mode édition
    _firstNameController = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user?.lastName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _passwordController = TextEditingController();
    _addressController = TextEditingController(text: widget.user?.address ?? '');
    _nationalityController = TextEditingController(text: widget.user?.nationality ?? '');
    _emergencyContactController = TextEditingController(text: widget.user?.emergencyContact ?? '');
    _birthDateController = TextEditingController(
      text: widget.user?.birthDate != null
          ? _formatDate(widget.user!.birthDate!)
          : '',
    );

    // Initialiser les variables de sélection
    _selectedRole = widget.user?.role ?? _availableRoles[0];
    _selectedGender = widget.user?.gender ?? _availableGenders[0];
    _isActive = widget.user?.isActive ?? true;
    _birthDate = widget.user?.birthDate;
  }

  // Méthode pour formater une date en chaîne dd/MM/yyyy
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Méthode pour analyser une chaîne dd/MM/yyyy en DateTime
  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    // Libérer les contrôleurs à la destruction du widget
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _emergencyContactController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer/mettre à jour l'objet utilisateur avec les valeurs du formulaire
      final user = User(
        id: _isEditMode ? widget.user!.id : '', // L'ID sera défini par le service en création
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        username: _usernameController.text,
        role: _selectedRole,
        isActive: _isActive,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        nationality: _nationalityController.text.isNotEmpty ? _nationalityController.text : null,
        emergencyContact: _emergencyContactController.text.isNotEmpty ? _emergencyContactController.text : null,
        gender: _selectedGender,
        birthDate: _birthDate,
        // Conserver certaines valeurs en mode édition
        creationDate: _isEditMode ? widget.user!.creationDate : DateTime.now(),
        lastLoginDate: _isEditMode ? widget.user!.lastLoginDate : null,
        profileImageUrl: _isEditMode && widget.user!.profileImageUrl != null
            ? widget.user!.profileImageUrl
            : '',
        completedCourses: _isEditMode && widget.user!.completedCourses != null
            ? widget.user!.completedCourses
            : [],
        inProgressCourses: _isEditMode && widget.user!.inProgressCourses != null
            ? widget.user!.inProgressCourses
            : [],
        childrenIds: _isEditMode && widget.user!.childrenIds != null
            ? widget.user!.childrenIds
            : [],
      );

      if (_isEditMode) {
        // Mettre à jour l'utilisateur existant
        await _userService.updateUser(user);
        if (_passwordController.text.isNotEmpty) {
          // Mettre à jour le mot de passe séparément si fourni
          await _userService.updateUserPassword(user.id, _passwordController.text);
        }
      } else {
        // Créer un nouvel utilisateur
        await _userService.createUser(
          user,
          _passwordController.text,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'L\'utilisateur a été mis à jour avec succès'
                : 'L\'utilisateur a été créé avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Retourner à la page précédente avec succès
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Afficher un message d'erreur
      _showErrorSnackBar('Erreur: $e');
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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier l\'utilisateur' : 'Créer un utilisateur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section des informations personnelles
              _buildSectionTitle('Informations personnelles'),
              _buildCard([
                // Prénom et nom
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        prefixIcon: Icons.person_outline,
                        validator: (value) => Validators.required(value, 'Le prénom est requis'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        prefixIcon: Icons.person_outline,
                        validator: (value) => Validators.required(value, 'Le nom est requis'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date de naissance et genre
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _birthDateController,
                        label: 'Date de naissance',
                        prefixIcon: Icons.cake,
                        readOnly: true,
                        onTap: _selectBirthDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Genre',
                        value: _selectedGender,
                        items: _availableGenders,
                        prefixIcon: Icons.person_pin,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Adresse
                _buildTextField(
                  controller: _addressController,
                  label: 'Adresse',
                  prefixIcon: Icons.home,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Nationalité
                _buildTextField(
                  controller: _nationalityController,
                  label: 'Nationalité',
                  prefixIcon: Icons.flag,
                ),
              ]),
              const SizedBox(height: 20),

              // Section des informations de contact
              _buildSectionTitle('Informations de contact'),
              _buildCard([
                // Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => Validators.email(value),
                ),
                const SizedBox(height: 16),

                // Téléphone
                _buildTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Contact d'urgence
                _buildTextField(
                  controller: _emergencyContactController,
                  label: 'Contact d\'urgence',
                  prefixIcon: Icons.emergency,
                  keyboardType: TextInputType.phone,
                ),
              ]),
              const SizedBox(height: 20),

              // Section des informations d'accès
              _buildSectionTitle('Informations d\'accès'),
              _buildCard([
                // Nom d'utilisateur
                _buildTextField(
                  controller: _usernameController,
                  label: 'Nom d\'utilisateur',
                  prefixIcon: Icons.account_circle,
                  validator: (value) => Validators.required(value, 'Le nom d\'utilisateur est requis'),
                ),
                const SizedBox(height: 16),

                // Mot de passe (requis seulement en création)
                _buildTextField(
                  controller: _passwordController,
                  label: _isEditMode ? 'Nouveau mot de passe (laisser vide pour conserver l\'actuel)' : 'Mot de passe',
                  prefixIcon: Icons.lock,
                  obscureText: !_passwordVisible,
                  validator: _isEditMode
                      ? null
                      : (value) => Validators.required(value, 'Le mot de passe est requis'),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Rôle
                _buildDropdown(
                  label: 'Rôle',
                  value: _getRoleDisplayName(_selectedRole),
                  items: _displayRoles,
                  prefixIcon: Icons.badge,
                  onChanged: (value) {
                    if (value != null) {
                      final index = _displayRoles.indexOf(value);
                      if (index >= 0) {
                        setState(() {
                          _selectedRole = _availableRoles[index];
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Statut (actif/inactif)
                SwitchListTile(
                  title: const Text('Utilisateur actif'),
                  value: _isActive,
                  activeColor: Theme.of(context).primaryColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: Icon(
                    _isActive ? Icons.check_circle : Icons.cancel,
                    color: _isActive ? Colors.green : Colors.red,
                  ),
                  onChanged: (bool value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ]),
              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isEditMode ? 'Mettre à jour' : 'Créer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Convertit un code de rôle en nom d'affichage
  String _getRoleDisplayName(String roleCode) {
    final index = _availableRoles.indexOf(roleCode);
    if (index >= 0 && index < _displayRoles.length) {
      return _displayRoles[index];
    }
    return roleCode;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData prefixIcon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}