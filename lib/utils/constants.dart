// Constantes globales de la aplicación Running Coach App

/// Colecciones de Firestore
class Collections {
  static const String users = 'users';
  static const String routines = 'routines';
  static const String workouts = 'workouts';
  static const String assignments = 'assignments';
  static const String trainingSessions = 'trainingSessions';
  static const String messages = 'messages';
}

/// Roles de usuario
class Roles {
  static const String coach = 'coach';
  static const String student = 'student';
}

/// Tipos de workout
class WorkoutTypes {
  static const String continuous = 'continuous';
  static const String intervals = 'intervals';
  static const String fartlek = 'fartlek';
  static const String series = 'series';
  static const String recovery = 'recovery';

  static const Map<String, String> labels = {
    continuous: 'Continuo',
    intervals: 'Intervalos',
    fartlek: 'Fartlek',
    series: 'Series',
    recovery: 'Recuperación',
  };
}

/// Niveles de rutina
class RoutineLevels {
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String advanced = 'advanced';

  static const Map<String, String> labels = {
    beginner: 'Principiante',
    intermediate: 'Intermedio',
    advanced: 'Avanzado',
  };
}

/// Estados de asignación
class AssignmentStatus {
  static const String active = 'active';
  static const String completed = 'completed';
  static const String paused = 'paused';
}

/// Estados de sesión de entrenamiento
class SessionStatus {
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String skipped = 'skipped';
}

/// Días de la semana
class WeekDays {
  static const List<String> labels = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
}

/// Mensajes de error
class ErrorMessages {
  static const String genericError = 'Ocurrió un error inesperado.';
  static const String networkError = 'Error de conexión. Verifica tu internet.';
  static const String authError = 'Error de autenticación.';
  static const String permissionDenied = 'Permisos insuficientes.';
  static const String userNotFound = 'Usuario no encontrado.';
  static const String wrongPassword = 'Contraseña incorrecta.';
  static const String emailInUse = 'El email ya está en uso.';
}

/// Mensajes de éxito
class SuccessMessages {
  static const String routineCreated = 'Rutina creada exitosamente.';
  static const String routineAssigned = 'Rutina asignada exitosamente.';
  static const String sessionCompleted = 'Entrenamiento completado.';
  static const String profileUpdated = 'Perfil actualizado.';
}

/// Rutas de navegación
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String coachHome = '/coach/home';
  static const String studentHome = '/student/home';
  static const String createRoutine = '/coach/create-routine';
  static const String assignRoutine = '/coach/assign-routine';
  static const String studentsList = '/coach/students';
  static const String myRoutines = '/student/routines';
  static const String calendar = '/student/calendar';
  static const String workoutDetail = '/student/workout-detail';
  static const String statistics = '/student/statistics';
  static const String chatRoom = '/chat/room';
}
