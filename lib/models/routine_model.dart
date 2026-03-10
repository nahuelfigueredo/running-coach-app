/// Modelo de rutina de entrenamiento para Running Coach App
class RoutineModel {
  final String id;
  final String name;
  final String description;
  final String coachId;
  final String? studentId;
  final String level; // 'beginner' | 'intermediate' | 'advanced'
  final int durationWeeks;
  final List<String> goals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const RoutineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coachId,
    this.studentId,
    required this.level,
    required this.durationWeeks,
    required this.goals,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  /// Crea un RoutineModel desde un mapa de Firestore
  factory RoutineModel.fromMap(Map<String, dynamic> map, String id) {
    return RoutineModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      coachId: map['coachId'] as String? ?? '',
      studentId: map['studentId'] as String?,
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
      startDate: map['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['startDate'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['endDate'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'coachId': coachId,
      if (studentId != null) 'studentId': studentId,
      'level': level,
      'durationWeeks': durationWeeks,
      'goals': goals,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'isActive': isActive,
    };
  }

  /// Crea una copia del modelo con campos modificados
  RoutineModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coachId,
    String? studentId,
    String? level,
    int? durationWeeks,
    List<String>? goals,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coachId: coachId ?? this.coachId,
      studentId: studentId ?? this.studentId,
      level: level ?? this.level,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      goals: goals ?? this.goals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'RoutineModel(id: $id, name: $name, level: $level)';
  }
}
