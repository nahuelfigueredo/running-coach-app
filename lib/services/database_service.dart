import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/routine_model.dart';
import '../models/workout_model.dart';
import '../models/assignment_model.dart';
import '../models/training_session_model.dart';
import '../utils/constants.dart';

/// Servicio de base de datos con Cloud Firestore
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Convierte errores de Firestore en [Exception] con mensajes legibles.
  ///
  /// Detecta errores de tipo [FirebaseException] y, en particular,
  /// los errores de índices faltantes (`failed-precondition`), retornando
  /// mensajes amigables en lugar de los mensajes técnicos de Firebase.
  Exception _handleFirestoreError(dynamic e) {
    if (e is FirebaseException) {
      if (e.code == 'failed-precondition' &&
          (e.message?.contains('index') ?? false)) {
        return Exception(
          'La aplicación necesita configuración adicional. '
          'Por favor contacta al administrador o crea los índices necesarios en Firebase Console. '
          'Consulta FIRESTORE_SETUP.md para más información.',
        );
      }
      return Exception('Error de base de datos: ${e.message}');
    }
    return Exception('Error inesperado: $e');
  }

  // ─── USUARIOS ────────────────────────────────────────────────────────────────

  /// Crea un nuevo documento de usuario en Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene un usuario por su ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(Collections.users).doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Actualiza los datos de un usuario
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(Collections.users).doc(uid).update(data);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene todos los usuarios con un rol específico
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.users)
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene los alumnos asignados a un coach
  Future<List<UserModel>> getStudentsByCoach(String coachId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.users)
          .where('role', isEqualTo: Roles.student)
          .where('coachId', isEqualTo: coachId)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ─── RUTINAS ─────────────────────────────────────────────────────────────────

  /// Crea una nueva rutina en Firestore
  Future<String> createRoutine(RoutineModel routine) async {
    try {
      final doc = await _firestore
          .collection(Collections.routines)
          .add(routine.toMap());
      return doc.id;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene una rutina específica por su ID
  Future<RoutineModel?> getRoutineById(String routineId) async {
    try {
      final doc = await _firestore
          .collection(Collections.routines)
          .doc(routineId)
          .get();
      if (!doc.exists) return null;
      return RoutineModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene todas las rutinas
  Future<List<RoutineModel>> getRoutines() async {
    try {
      final snapshot =
          await _firestore.collection(Collections.routines).get();
      return snapshot.docs
          .map((doc) => RoutineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene las rutinas creadas por un coach
  Future<List<RoutineModel>> getRoutinesByCoach(String coachId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.routines)
          .where('coachId', isEqualTo: coachId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => RoutineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene las rutinas asignadas a un alumno específico
  Future<List<RoutineModel>> getRoutinesByStudent(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.routines)
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => RoutineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Actualiza una rutina existente
  Future<void> updateRoutine(String routineId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(Collections.routines)
          .doc(routineId)
          .update({...data, 'updatedAt': DateTime.now()});
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Elimina una rutina
  Future<void> deleteRoutine(String routineId) async {
    try {
      await _firestore
          .collection(Collections.routines)
          .doc(routineId)
          .delete();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ─── WORKOUTS ────────────────────────────────────────────────────────────────

  /// Agrega un workout a una rutina
  Future<String> addWorkoutToRoutine(WorkoutModel workout) async {
    try {
      final doc = await _firestore
          .collection(Collections.workouts)
          .add(workout.toMap());
      return doc.id;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene todos los workouts de una rutina
  Future<List<WorkoutModel>> getWorkouts(String routineId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.workouts)
          .where('routineId', isEqualTo: routineId)
          .orderBy('order')
          .get();
      return snapshot.docs
          .map((doc) => WorkoutModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Actualiza un workout existente
  Future<void> updateWorkout(
      String workoutId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(Collections.workouts)
          .doc(workoutId)
          .update(data);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Elimina un workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _firestore
          .collection(Collections.workouts)
          .doc(workoutId)
          .delete();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ─── ASIGNACIONES ────────────────────────────────────────────────────────────

  /// Asigna una rutina a un alumno
  Future<String> assignRoutine(AssignmentModel assignment) async {
    try {
      final doc = await _firestore
          .collection(Collections.assignments)
          .add(assignment.toMap());
      return doc.id;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene las asignaciones de un alumno
  Future<List<AssignmentModel>> getAssignmentsByStudent(
      String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.assignments)
          .where('studentId', isEqualTo: studentId)
          .orderBy('assignedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene las asignaciones creadas por un coach
  Future<List<AssignmentModel>> getAssignmentsByCoach(String coachId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.assignments)
          .where('coachId', isEqualTo: coachId)
          .orderBy('assignedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Actualiza el estado de una asignación
  Future<void> updateAssignment(
      String assignmentId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(Collections.assignments)
          .doc(assignmentId)
          .update(data);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ─── SESIONES DE ENTRENAMIENTO ───────────────────────────────────────────────

  /// Crea una sesión de entrenamiento
  Future<String> createSession(TrainingSessionModel session) async {
    try {
      final doc = await _firestore
          .collection(Collections.trainingSessions)
          .add(session.toMap());
      return doc.id;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene las sesiones de un alumno
  Future<List<TrainingSessionModel>> getSessionsByStudent(
      String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.trainingSessions)
          .where('studentId', isEqualTo: studentId)
          .orderBy('scheduledDate')
          .get();
      return snapshot.docs
          .map((doc) => TrainingSessionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Marca una sesión como completada
  Future<void> completeSession(
    String sessionId, {
    double? actualDistance,
    int? actualDuration,
    String? notes,
  }) async {
    try {
      await _firestore
          .collection(Collections.trainingSessions)
          .doc(sessionId)
          .update({
        'status': SessionStatus.completed,
        'completedAt': DateTime.now(),
        if (actualDistance != null) 'actualDistance': actualDistance,
        if (actualDuration != null) 'actualDuration': actualDuration,
        if (notes != null) 'notes': notes,
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  /// Obtiene estadísticas de un alumno
  Future<Map<String, dynamic>> getStudentStatistics(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.trainingSessions)
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: SessionStatus.completed)
          .get();

      final sessions = snapshot.docs
          .map((doc) => TrainingSessionModel.fromMap(doc.data(), doc.id))
          .toList();

      final totalDistance = sessions.fold<double>(
        0,
        (sum, s) => sum + (s.actualDistance ?? 0),
      );
      final totalDuration = sessions.fold<int>(
        0,
        (sum, s) => sum + (s.actualDuration ?? 0),
      );

      return {
        'totalSessions': sessions.length,
        'totalDistance': totalDistance,
        'totalDuration': totalDuration,
      };
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
}
