/// Modelo de sesión de entrenamiento para Running Coach App
class TrainingSessionModel {
  final String id;
  final String workoutId;
  final String studentId;
  final String assignmentId;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final String status; // 'pending' | 'completed' | 'skipped'
  final double? actualDistance;
  final int? actualDuration;
  final String? notes;

  const TrainingSessionModel({
    required this.id,
    required this.workoutId,
    required this.studentId,
    required this.assignmentId,
    required this.scheduledDate,
    this.completedAt,
    required this.status,
    this.actualDistance,
    this.actualDuration,
    this.notes,
  });

  /// Crea un TrainingSessionModel desde un mapa de Firestore
  factory TrainingSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return TrainingSessionModel(
      id: id,
      workoutId: map['workoutId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      assignmentId: map['assignmentId'] as String? ?? '',
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['scheduledDate'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['completedAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      status: map['status'] as String? ?? 'pending',
      actualDistance: (map['actualDistance'] as num?)?.toDouble(),
      actualDuration: (map['actualDuration'] as num?)?.toInt(),
      notes: map['notes'] as String?,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'studentId': studentId,
      'assignmentId': assignmentId,
      'scheduledDate': scheduledDate,
      if (completedAt != null) 'completedAt': completedAt,
      'status': status,
      if (actualDistance != null) 'actualDistance': actualDistance,
      if (actualDuration != null) 'actualDuration': actualDuration,
      if (notes != null) 'notes': notes,
    };
  }

  /// Crea una copia del modelo con campos modificados
  TrainingSessionModel copyWith({
    String? id,
    String? workoutId,
    String? studentId,
    String? assignmentId,
    DateTime? scheduledDate,
    DateTime? completedAt,
    String? status,
    double? actualDistance,
    int? actualDuration,
    String? notes,
  }) {
    return TrainingSessionModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      studentId: studentId ?? this.studentId,
      assignmentId: assignmentId ?? this.assignmentId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      actualDistance: actualDistance ?? this.actualDistance,
      actualDuration: actualDuration ?? this.actualDuration,
      notes: notes ?? this.notes,
    );
  }

  /// Verifica si la sesión fue completada
  bool get isCompleted => status == 'completed';

  /// Verifica si la sesión está pendiente
  bool get isPending => status == 'pending';

  @override
  String toString() {
    return 'TrainingSessionModel(id: $id, workoutId: $workoutId, status: $status)';
  }
}
