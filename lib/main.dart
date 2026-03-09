import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/coach/coach_home_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'utils/theme.dart';

/// Punto de entrada principal de Running Coach App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RunningCoachApp());
}

class RunningCoachApp extends StatelessWidget {
  const RunningCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Running Coach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthWrapper(),
      ),
    );
  }
}

/// Wrapper de autenticación: redirige según el estado del usuario
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Mostrar indicador mientras carga
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Usuario no autenticado → pantalla de login
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // Redirigir según el rol del usuario
    final user = auth.currentUser!;
    if (user.isCoach) {
      return const CoachHomeScreen();
    } else {
      return const StudentHomeScreen();
    }
  }
}
