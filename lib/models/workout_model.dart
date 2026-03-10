/// Modelo de workout (entrenamiento individual) para Running Coach App
class WorkoutModel {
  final String id;
  final String routineId;
  final String name;
  final String type; // 'continuous' | 'intervals' | 'fartlek' | 'series' | 'recovery' | etc.
  final String description;
  final double distance; // km
  final int duration; // minutos
  final String pace; // "5:30"
  final int dayOfWeek; // 0-6 (0 = lunes)
  final int order;
  final String intensity; // 'easy' | 'moderate' | 'hard' | 'maximum'
  final int? series;
  final int? restTime; // segundos
  final String? notes;

  /// Ritmo objetivo en formato min/km, ej: '5:30'
  final String? targetPace;

  /// Zona de frecuencia cardíaca objetivo, ej: 'Z2: 140-150 bpm'
  final String? heartRateZone;

  /// Detalles específicos para entrenamientos de intervalos
  final Map<String, dynamic>? intervalDetails;

  /// Fecha de creación del workout
  final DateTime? createdAt;

  const WorkoutModel({
    required this.id,
    required this.routineId,
    required this.name,
    required this.type,
    required this.description,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.dayOfWeek,
    required this.order,
    this.intensity = 'easy',
    this.series,
    this.restTime,
    this.notes,
    this.targetPace,
    this.heartRateZone,
    this.intervalDetails,
    this.createdAt,
  });

  /// Crea un WorkoutModel desde un mapa de Firestore
  factory WorkoutModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutModel(
      id: id,
      routineId: map['routineId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'continuous',
      description: map['description'] as String? ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      pace: map['pace'] as String? ?? '',
      dayOfWeek: (map['dayOfWeek'] as num?)?.toInt() ?? 0,
      order: (map['order'] as num?)?.toInt() ?? 0,
      intensity: map['intensity'] as String? ?? 'easy',
      series: (map['series'] as num?)?.toInt(),
      restTime: (map['restTime'] as num?)?.toInt(),
      notes: map['notes'] as String?,
      targetPace: map['targetPace'] as String?,
      heartRateZone: map['heartRateZone'] as String?,
      intervalDetails: map['intervalDetails'] as Map<String, dynamic>?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'routineId': routineId,
      'name': name,
      'type': type,
      'description': description,
      'distance': distance,
      'duration': duration,
      'pace': pace,
      'dayOfWeek': dayOfWeek,
      'order': order,
      'intensity': intensity,
      if (series != null) 'series': series,
      if (restTime != null) 'restTime': restTime,
      if (notes != null) 'notes': notes,
      if (targetPace != null) 'targetPace': targetPace,
      if (heartRateZone != null) 'heartRateZone': heartRateZone,
      if (intervalDetails != null) 'intervalDetails': intervalDetails,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  /// Crea una copia del modelo con campos modificados
  WorkoutModel copyWith({
    String? id,
    String? routineId,
    String? name,
    String? type,
    String? description,
    double? distance,
    int? duration,
    String? pace,
    int? dayOfWeek,
    int? order,
    String? intensity,
    int? series,
    int? restTime,
    String? notes,
    String? targetPace,
    String? heartRateZone,
    Map<String, dynamic>? intervalDetails,
    DateTime? createdAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      pace: pace ?? this.pace,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      order: order ?? this.order,
      intensity: intensity ?? this.intensity,
      series: series ?? this.series,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      targetPace: targetPace ?? this.targetPace,
      heartRateZone: heartRateZone ?? this.heartRateZone,
      intervalDetails: intervalDetails ?? this.intervalDetails,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Emoji representativo del tipo de entrenamiento
  String get typeEmoji {
    switch (type) {
      case 'continuous':
        return '🏃';
      case 'intervals':
        return '💪';
      case 'fartlek':
        return '⚡';
      case 'hills':
        return '🏔️';
      case 'active_rest':
        return '🧘';
      case 'rest':
        return '😴';
      case 'strength':
        return '🏋️';
      case 'series':
        return '🔄';
      case 'recovery':
        return '🧘';
      default:
        return '🏃';
    }
  }

  /// Nombre legible del tipo de entrenamiento
  String get typeName {
    switch (type) {
      case 'continuous':
        return 'Carrera Continua';
      case 'intervals':
        return 'Intervalos';
      case 'fartlek':
        return 'Fartlek';
      case 'hills':
        return 'Cuestas';
      case 'active_rest':
        return 'Descanso Activo';
      case 'rest':
        return 'Descanso';
      case 'strength':
        return 'Fortalecimiento';
      case 'series':
        return 'Series';
      case 'recovery':
        return 'Recuperación';
      default:
        return 'Entrenamiento';
    }
  }

  /// Color hexadecimal representativo de la intensidad
  String get intensityColor {
    switch (intensity) {
      case 'easy':
        return '#10B981';
      case 'moderate':
        return '#F59E0B';
      case 'hard':
        return '#EF4444';
      case 'maximum':
        return '#7C3AED';
      default:
        return '#6B7280';
    }
  }

  @override
  String toString() {
    return 'WorkoutModel(id: $id, name: $name, type: $type)';
  }
}
