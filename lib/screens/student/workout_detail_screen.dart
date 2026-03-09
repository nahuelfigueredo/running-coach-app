import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/training_session_model.dart';
import '../../models/workout_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/workout_card.dart';

/// Pantalla de detalle de workout y lista de sesiones de una rutina
class WorkoutDetailScreen extends StatefulWidget {
  final String routineId;
  final String routineName;
  final String assignmentId;

  const WorkoutDetailScreen({
    super.key,
    required this.routineId,
    required this.routineName,
    required this.assignmentId,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  List<WorkoutModel> _workouts = [];
  List<TrainingSessionModel> _sessions = [];
  bool _isLoading = true;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    try {
      final workouts = await _db.getWorkouts(widget.routineId);
      final allSessions = await _db.getSessionsByStudent(auth.currentUser!.uid);
      final sessions = allSessions
          .where((s) => s.assignmentId == widget.assignmentId)
          .toList();
      setState(() {
        _workouts = workouts;
        _sessions = sessions;
      });
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  /// Obtiene la sesión de un workout
  TrainingSessionModel? _getSession(String workoutId) {
    try {
      return _sessions.firstWhere((s) => s.workoutId == workoutId);
    } catch (_) {
      return null;
    }
  }

  /// Muestra el diálogo para completar un workout
  Future<void> _showCompleteDialog(WorkoutModel workout) async {
    final distanceController = TextEditingController(
      text: workout.distance > 0 ? workout.distance.toString() : '',
    );
    final durationController = TextEditingController(
      text: workout.duration > 0 ? workout.duration.toString() : '',
    );
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar entrenamiento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Registra los datos reales del entrenamiento:'),
              const SizedBox(height: 16),
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distancia real (km)',
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración real (min)',
                  prefixIcon: Icon(Icons.timer),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _completeSession(
                workout,
                actualDistance: double.tryParse(distanceController.text),
                actualDuration: int.tryParse(durationController.text),
                notes: notesController.text.isNotEmpty
                    ? notesController.text
                    : null,
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSession(
    WorkoutModel workout, {
    double? actualDistance,
    int? actualDuration,
    String? notes,
  }) async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    try {
      // Buscar o crear la sesión
      TrainingSessionModel? session = _getSession(workout.id);

      if (session == null) {
        // Crear la sesión
        final newSession = TrainingSessionModel(
          id: '',
          workoutId: workout.id,
          studentId: auth.currentUser!.uid,
          assignmentId: widget.assignmentId,
          scheduledDate: DateTime.now(),
          status: SessionStatus.pending,
        );
        final sessionId = await _db.createSession(newSession);
        session = newSession.copyWith(id: sessionId);
      }

      // Marcar como completada
      await _db.completeSession(
        session.id,
        actualDistance: actualDistance,
        actualDuration: actualDuration,
        notes: notes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(SuccessMessages.sessionCompleted),
          backgroundColor: AppTheme.successColor,
        ),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: Text(widget.routineName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fitness_center_outlined,
                          size: 72, color: AppTheme.textLight),
                      SizedBox(height: 16),
                      Text(
                        'Esta rutina no tiene workouts aún.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) {
                    final workout = _workouts[index];
                    final session = _getSession(workout.id);
                    return WorkoutCard(
                      workout: workout,
                      status: session?.status,
                      onTap: () => _showWorkoutDetails(workout, session),
                      onComplete: session?.status != SessionStatus.completed
                          ? () => _showCompleteDialog(workout)
                          : null,
                    );
                  },
                ),
    );
  }

  void _showWorkoutDetails(WorkoutModel workout, TrainingSessionModel? session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          final typeColor = AppTheme.getWorkoutTypeColor(workout.type);
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  workout.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    WorkoutTypes.labels[workout.type] ?? workout.type,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _detailRow('Descripción', workout.description),
                if (workout.distance > 0)
                  _detailRow(
                      'Distancia', '${workout.distance.toStringAsFixed(1)} km'),
                if (workout.duration > 0)
                  _detailRow('Duración', '${workout.duration} min'),
                if (workout.pace.isNotEmpty)
                  _detailRow('Ritmo objetivo', workout.pace),
                const SizedBox(height: 24),
                if (session?.status != SessionStatus.completed)
                  CustomButton(
                    text: 'Marcar como completado',
                    onPressed: () {
                      Navigator.pop(context);
                      _showCompleteDialog(workout);
                    },
                    icon: Icons.check_circle_outline,
                  ),
                if (session?.status == SessionStatus.completed &&
                    session?.actualDistance != null)
                  _detailRow(
                    'Distancia real',
                    '${session!.actualDistance!.toStringAsFixed(1)} km',
                  ),
                if (session?.notes != null)
                  _detailRow('Notas', session!.notes!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}
