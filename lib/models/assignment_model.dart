/// Modelo de asignación de rutina a alumno para Running Coach App
class AssignmentModel {
  final String id;
  final String routineId;
  final String studentId;
  final String coachId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active' | 'completed' | 'paused'
  final DateTime assignedAt;

  const AssignmentModel({
    required this.id,
    required this.routineId,
    required this.studentId,
    required this.coachId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.assignedAt,
  });

  /// Crea un AssignmentModel desde un mapa de Firestore
  factory AssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssignmentModel(
      id: id,
      routineId: map['routineId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      coachId: map['coachId'] as String? ?? '',
      startDate: map['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['startDate'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['endDate'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now().add(const Duration(days: 30)),
      status: map['status'] as String? ?? 'active',
      assignedAt: map['assignedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['assignedAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'routineId': routineId,
      'studentId': studentId,
      'coachId': coachId,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'assignedAt': assignedAt,
    };
  }

  /// Crea una copia del modelo con campos modificados
  AssignmentModel copyWith({
    String? id,
    String? routineId,
    String? studentId,
    String? coachId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? assignedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      studentId: studentId ?? this.studentId,
      coachId: coachId ?? this.coachId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }

  /// Verifica si la asignación está activa
  bool get isActive => status == 'active';

  @override
  String toString() {
    return 'AssignmentModel(id: $id, routineId: $routineId, studentId: $studentId, status: $status)';
  }
}
