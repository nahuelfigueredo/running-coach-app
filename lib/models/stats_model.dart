/// Modelo de estadísticas del alumno para Running Coach App
class StatsModel {
  final int totalSessions;
  final double totalDistance; // km
  final int totalDuration; // minutos
  final int currentStreak; // días consecutivos
  final int longestStreak; // días
  final String? bestPace; // min/km
  final double? longestRun; // km
  final int? totalCalories;

  /// Distribución de sesiones por tipo: {'continuous': 10, 'intervals': 5}
  final Map<String, int> workoutTypeDistribution;

  /// Distancia semanal acumulada: {'2026-W10': 32.5}
  final Map<String, double> weeklyDistance;

  /// Fecha del último entrenamiento completado
  final DateTime? lastWorkout;

  StatsModel({
    required this.totalSessions,
    required this.totalDistance,
    required this.totalDuration,
    required this.currentStreak,
    required this.longestStreak,
    this.bestPace,
    this.longestRun,
    this.totalCalories,
    required this.workoutTypeDistribution,
    required this.weeklyDistance,
    this.lastWorkout,
  });

  /// Crea un [StatsModel] vacío, útil como valor inicial.
  factory StatsModel.empty() {
    return StatsModel(
      totalSessions: 0,
      totalDistance: 0,
      totalDuration: 0,
      currentStreak: 0,
      longestStreak: 0,
      workoutTypeDistribution: {},
      weeklyDistance: {},
    );
  }

  /// Crea un [StatsModel] desde un mapa de Firestore.
  factory StatsModel.fromMap(Map<String, dynamic> map) {
    return StatsModel(
      totalSessions: (map['totalSessions'] as num?)?.toInt() ?? 0,
      totalDistance: (map['totalDistance'] as num?)?.toDouble() ?? 0.0,
      totalDuration: (map['totalDuration'] as num?)?.toInt() ?? 0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      bestPace: map['bestPace'] as String?,
      longestRun: (map['longestRun'] as num?)?.toDouble(),
      totalCalories: (map['totalCalories'] as num?)?.toInt(),
      workoutTypeDistribution:
          Map<String, int>.from(map['workoutTypeDistribution'] as Map? ?? {}),
      weeklyDistance: Map<String, double>.from(
        ((map['weeklyDistance'] as Map?) ?? {}).map(
          (key, value) =>
              MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      lastWorkout: map['lastWorkout'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['lastWorkout'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
    );
  }

  /// Convierte el modelo a un mapa para Firestore.
  Map<String, dynamic> toMap() {
    return {
      'totalSessions': totalSessions,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      if (bestPace != null) 'bestPace': bestPace,
      if (longestRun != null) 'longestRun': longestRun,
      if (totalCalories != null) 'totalCalories': totalCalories,
      'workoutTypeDistribution': workoutTypeDistribution,
      'weeklyDistance': weeklyDistance,
      if (lastWorkout != null) 'lastWorkout': lastWorkout,
    };
  }

  /// Distancia acumulada en la semana actual.
  double get currentWeekDistance {
    final now = DateTime.now();
    final weekKey = _getWeekKey(now);
    return weeklyDistance[weekKey] ?? 0;
  }

  /// Ritmo promedio calculado a partir de las estadísticas totales.
  String get averagePace {
    if (totalDistance == 0 || totalDuration == 0) return '--';
    final paceMinutes = totalDuration / totalDistance;
    final mins = paceMinutes.floor();
    final secs = ((paceMinutes - mins) * 60).round();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  // ─── Internos ─────────────────────────────────────────────────────────────

  String _getWeekKey(DateTime date) {
    final weekNumber = _getWeekNumber(date);
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  @override
  String toString() {
    return 'StatsModel(totalSessions: $totalSessions, '
        'totalDistance: $totalDistance km, currentStreak: $currentStreak)';
  }
}
