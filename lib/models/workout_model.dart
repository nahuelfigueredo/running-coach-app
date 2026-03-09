/// Modelo de workout (entrenamiento individual) para Running Coach App
class WorkoutModel {
  final String id;
  final String routineId;
  final String name;
  final String type; // 'continuous' | 'intervals' | 'fartlek' | 'series' | 'recovery'
  final String description;
  final double distance; // km
  final int duration; // minutos
  final String pace; // "5:30"
  final int dayOfWeek; // 0-6 (0 = lunes)
  final int order;

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
    );
  }

  @override
  String toString() {
    return 'WorkoutModel(id: $id, name: $name, type: $type)';
  }
}
