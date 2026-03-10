/// Modelo de sesión de entrenamiento para Running Coach App
class TrainingSessionModel {
  final String id;
  final String workoutId;
  final String studentId;
  final String assignmentId;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final String status; // 'pending' | 'completed' | 'skipped' | 'in_progress'
  final double? actualDistance;
  final int? actualDuration;
  final String? notes;

  /// ID de la rutina a la que pertenece esta sesión
  final String? routineId;

  /// Inicio real del entrenamiento
  final DateTime? startTime;

  /// Fin real del entrenamiento
  final DateTime? endTime;

  /// Ritmo promedio real en formato min/km
  final String? averagePace;

  /// Frecuencia cardíaca promedio en bpm
  final int? averageHeartRate;

  /// Frecuencia cardíaca máxima en bpm
  final int? maxHeartRate;

  /// Calorías quemadas
  final int? calories;

  /// Datos GPS de la sesión
  final Map<String, dynamic>? gpsData;

  /// Fecha de creación del registro
  final DateTime? createdAt;

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
    this.routineId,
    this.startTime,
    this.endTime,
    this.averagePace,
    this.averageHeartRate,
    this.maxHeartRate,
    this.calories,
    this.gpsData,
    this.createdAt,
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
      routineId: map['routineId'] as String?,
      startTime: map['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['startTime'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['endTime'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      averagePace: map['averagePace'] as String?,
      averageHeartRate: (map['averageHeartRate'] as num?)?.toInt(),
      maxHeartRate: (map['maxHeartRate'] as num?)?.toInt(),
      calories: (map['calories'] as num?)?.toInt(),
      gpsData: map['gpsData'] as Map<String, dynamic>?,
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
      'workoutId': workoutId,
      'studentId': studentId,
      'assignmentId': assignmentId,
      'scheduledDate': scheduledDate,
      if (completedAt != null) 'completedAt': completedAt,
      'status': status,
      if (actualDistance != null) 'actualDistance': actualDistance,
      if (actualDuration != null) 'actualDuration': actualDuration,
      if (notes != null) 'notes': notes,
      if (routineId != null) 'routineId': routineId,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (averagePace != null) 'averagePace': averagePace,
      if (averageHeartRate != null) 'averageHeartRate': averageHeartRate,
      if (maxHeartRate != null) 'maxHeartRate': maxHeartRate,
      if (calories != null) 'calories': calories,
      if (gpsData != null) 'gpsData': gpsData,
      if (createdAt != null) 'createdAt': createdAt,
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
    String? routineId,
    DateTime? startTime,
    DateTime? endTime,
    String? averagePace,
    int? averageHeartRate,
    int? maxHeartRate,
    int? calories,
    Map<String, dynamic>? gpsData,
    DateTime? createdAt,
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
      routineId: routineId ?? this.routineId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      averagePace: averagePace ?? this.averagePace,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      calories: calories ?? this.calories,
      gpsData: gpsData ?? this.gpsData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Duración real del entrenamiento en formato legible (hh:mm:ss o mm:ss)
  String get durationFormatted {
    final secs = actualDuration;
    if (secs == null) return '--';
    final hours = secs ~/ 3600;
    final minutes = (secs % 3600) ~/ 60;
    final seconds = secs % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  /// Verifica si la sesión fue completada
  bool get isCompleted => status == 'completed';

  /// Verifica si la sesión está en progreso
  bool get isInProgress => status == 'in_progress';

  /// Verifica si la sesión está pendiente
  bool get isPending => status == 'pending';

  @override
  String toString() {
    return 'TrainingSessionModel(id: $id, workoutId: $workoutId, status: $status)';
  }
}
