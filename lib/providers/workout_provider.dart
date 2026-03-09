import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../services/database_service.dart';

/// Provider de workouts para Running Coach App
class WorkoutProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga los workouts de una rutina específica
  Future<void> loadWorkouts(String routineId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _workouts = await _databaseService.getWorkouts(routineId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Agrega un nuevo workout a una rutina
  Future<bool> addWorkout(WorkoutModel workout) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final id = await _databaseService.addWorkoutToRoutine(workout);
      final newWorkout = workout.copyWith(id: id);
      _workouts.add(newWorkout);
      _workouts.sort((a, b) => a.order.compareTo(b.order));
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Actualiza un workout existente
  Future<bool> updateWorkout(WorkoutModel workout) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _databaseService.updateWorkout(workout.id, workout.toMap());
      final index = _workouts.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        _workouts[index] = workout;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Elimina un workout
  Future<bool> deleteWorkout(String workoutId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _databaseService.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Limpia la lista de workouts
  void clearWorkouts() {
    _workouts = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
