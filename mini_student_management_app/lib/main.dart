import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final studentProvider = StudentProvider();
  final authProvider = AuthProvider();

  await studentProvider.loadStudents();
  await authProvider.loadSavedUser();

  runApp(MyApp(
    studentProvider: studentProvider,
    authProvider: authProvider,
  ));
}

class MyApp extends StatelessWidget {
  final StudentProvider studentProvider;
  final AuthProvider authProvider;

  const MyApp({
    super.key,
    required this.studentProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentProvider>.value(
          value: studentProvider,
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
      ],
      child: MaterialApp(
        title: 'Student Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const DashboardScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

