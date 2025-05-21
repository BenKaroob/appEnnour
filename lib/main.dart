import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/index.dart';
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/course_list_page.dart';
import 'pages/course_detail_page.dart';
import 'pages/quiz_page.dart';
import 'pages/profile_page.dart';
import 'pages/admin/admin_login_page.dart';
import 'pages/admin/admin_dashboard_page.dart';
import 'pages/admin/admin_users_page.dart';
import 'services/theme_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.materialThemeMode,
      initialRoute: AppRoutes.initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}