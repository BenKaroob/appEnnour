import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Thème'),
            subtitle: const Text('Choisissez le mode d\'affichage'),
            trailing: DropdownButton<AppThemeMode>(
              value: themeService.themeMode,
              items: const [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text('Système'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text('Clair'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text('Sombre'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  themeService.setTheme(mode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
