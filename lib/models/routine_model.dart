/// Modelo de rutina de entrenamiento para Running Coach App
class RoutineModel {
  final String id;
  final String name;
  final String description;
  final String coachId;
  final String level; // 'beginner' | 'intermediate' | 'advanced'
  final int durationWeeks;
  final List<String> goals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoutineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coachId,
    required this.level,
    required this.durationWeeks,
    required this.goals,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea un RoutineModel desde un mapa de Firestore
  factory RoutineModel.fromMap(Map<String, dynamic> map, String id) {
    return RoutineModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      coachId: map['coachId'] as String? ?? '',
      level: map['level'] as String? ?? 'beginner',
      durationWeeks: (map['durationWeeks'] as num?)?.toInt() ?? 4,
      goals: List<String>.from(map['goals'] as List? ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['updatedAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'coachId': coachId,
      'level': level,
      'durationWeeks': durationWeeks,
      'goals': goals,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Crea una copia del modelo con campos modificados
  RoutineModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coachId,
    String? level,
    int? durationWeeks,
    List<String>? goals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coachId: coachId ?? this.coachId,
      level: level ?? this.level,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      goals: goals ?? this.goals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineModel(id: $id, name: $name, level: $level)';
  }
}
