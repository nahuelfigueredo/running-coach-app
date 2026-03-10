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
    );
  }

  @override
  String toString() {
    return 'WorkoutModel(id: $id, name: $name, type: $type)';
  }
}
