import 'package:flutter/foundation.dart';
import '../models/routine_model.dart';
import '../services/database_service.dart';

/// Provider de rutinas para Running Coach App
class RoutineProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<RoutineModel> _routines = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RoutineModel> get routines => _routines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga las rutinas de un coach
  Future<void> loadRoutines(String coachId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _routines = await _databaseService.getRoutinesByCoach(coachId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Crea una nueva rutina
  Future<bool> createRoutine(RoutineModel routine) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final id = await _databaseService.createRoutine(routine);
      final newRoutine = routine.copyWith(id: id);
      _routines.insert(0, newRoutine);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Actualiza una rutina existente
  Future<bool> updateRoutine(RoutineModel routine) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _databaseService.updateRoutine(routine.id, routine.toMap());
      final index = _routines.indexWhere((r) => r.id == routine.id);
      if (index != -1) {
        _routines[index] = routine;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Elimina una rutina
  Future<bool> deleteRoutine(String routineId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _databaseService.deleteRoutine(routineId);
      _routines.removeWhere((r) => r.id == routineId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
