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
  static const String hills = 'hills';
  static const String activeRest = 'active_rest';
  static const String rest = 'rest';
  static const String strength = 'strength';

  static const List<String> all = [
    continuous,
    intervals,
    fartlek,
    hills,
    activeRest,
    rest,
    strength,
  ];

  static const Map<String, String> labels = {
    continuous: 'Carrera continua',
    intervals: 'Intervalos',
    fartlek: 'Fartlek',
    series: 'Series',
    recovery: 'Recuperación',
    hills: 'Cuestas',
    activeRest: 'Descanso activo',
    rest: 'Descanso completo',
    strength: 'Fortalecimiento',
  };

  static const Map<String, String> icons = {
    continuous: '🏃',
    intervals: '💪',
    fartlek: '⚡',
    series: '🔄',
    recovery: '🧘',
    hills: '🏔️',
    activeRest: '🧘',
    rest: '😴',
    strength: '🏋️',
  };

  static String getName(String type) => labels[type] ?? 'Entrenamiento';
}

/// Intensidades de entrenamiento
class Intensity {
  static const String easy = 'easy';
  static const String moderate = 'moderate';
  static const String hard = 'hard';
  static const String maximum = 'maximum';

  static const Map<String, String> labels = {
    easy: 'Suave (60-70% FCMax)',
    moderate: 'Moderado (70-80% FCMax)',
    hard: 'Intenso (80-90% FCMax)',
    maximum: 'Máximo (>90% FCMax)',
  };
}

/// Niveles de intensidad (alias moderno de [Intensity] con helpers adicionales).
class IntensityLevels {
  static const String easy = 'easy';
  static const String moderate = 'moderate';
  static const String hard = 'hard';
  static const String maximum = 'maximum';

  static const List<String> all = [easy, moderate, hard, maximum];

  static String getName(String level) {
    switch (level) {
      case easy:
        return 'Fácil';
      case moderate:
        return 'Moderado';
      case hard:
        return 'Difícil';
      case maximum:
        return 'Máximo';
      default:
        return 'Moderado';
    }
  }
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
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String skipped = 'skipped';
}

/// Días de la semana
class WeekDays {
  static const String monday = 'monday';
  static const String tuesday = 'tuesday';
  static const String wednesday = 'wednesday';
  static const String thursday = 'thursday';
  static const String friday = 'friday';
  static const String saturday = 'saturday';
  static const String sunday = 'sunday';

  static const List<String> ordered = [
    monday, tuesday, wednesday, thursday, friday, saturday, sunday,
  ];

  /// Alias de [ordered] requerido por los nuevos modelos.
  static const List<String> all = ordered;

  static const Map<String, String> labels = {
    monday: 'Lunes',
    tuesday: 'Martes',
    wednesday: 'Miércoles',
    thursday: 'Jueves',
    friday: 'Viernes',
    saturday: 'Sábado',
    sunday: 'Domingo',
  };

  static const Map<String, String> shortLabels = {
    monday: 'Lun',
    tuesday: 'Mar',
    wednesday: 'Mié',
    thursday: 'Jue',
    friday: 'Vie',
    saturday: 'Sáb',
    sunday: 'Dom',
  };

  /// Convierte índice (0 = lunes) a clave de día
  static String fromIndex(int index) => ordered[index % 7];

  /// Convierte clave de día a índice (0 = lunes)
  static int toIndex(String day) {
    final idx = ordered.indexOf(day);
    return idx == -1 ? 0 : idx;
  }

  /// Nombre completo del día en español.
  static String getName(String day) => labels[day] ?? '';

  /// Nombre abreviado del día en español.
  static String getShortName(String day) => shortLabels[day] ?? '';
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
