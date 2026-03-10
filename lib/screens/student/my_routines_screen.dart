import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/assignment_model.dart';
import '../../models/routine_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';
import '../../utils/theme.dart';
import 'workout_detail_screen.dart';

/// Pantalla con las rutinas asignadas al alumno
class MyRoutinesScreen extends StatefulWidget {
  const MyRoutinesScreen({super.key});

  @override
  State<MyRoutinesScreen> createState() => _MyRoutinesScreenState();
}

class _MyRoutinesScreenState extends State<MyRoutinesScreen> {
  List<Map<String, dynamic>> _assignedRoutines = []; // {assignment, routine}
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser == null) return;
      final db = DatabaseService();

      // Obtener asignaciones del alumno
      final assignments =
          await db.getAssignmentsByStudent(auth.currentUser!.uid);

      // Obtener detalles de cada rutina DE FORMA EFICIENTE (en paralelo)
      final routineFutures = assignments
          .map((assignment) => db.getRoutineById(assignment.routineId))
          .toList();
      final routines = await Future.wait(routineFutures);

      final List<Map<String, dynamic>> result = [];
      for (int i = 0; i < assignments.length; i++) {
        result.add({
          'assignment': assignments[i],
          'routine': routines[i] ??
              RoutineModel(
                id: assignments[i].routineId,
                name: 'Rutina no encontrada',
                description: 'Esta rutina ya no está disponible',
                coachId: '',
                level: RoutineLevels.beginner,
                durationWeeks: 0,
                goals: [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        });
      }
      _assignedRoutines = result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAssignments, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (_assignedRoutines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_outlined, size: 72, color: AppTheme.textLight),
            SizedBox(height: 16),
            Text(
              'No tienes rutinas asignadas aún.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignedRoutines.length,
      itemBuilder: (context, index) {
        final item = _assignedRoutines[index];
        final assignment = item['assignment'] as AssignmentModel;
        final routine = item['routine'] as RoutineModel;
        return _AssignedRoutineCard(
          assignment: assignment,
          routine: routine,
        );
      },
    );
  }
}

class _AssignedRoutineCard extends StatelessWidget {
  final AssignmentModel assignment;
  final RoutineModel routine;

  const _AssignedRoutineCard({
    required this.assignment,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = assignment.status == AssignmentStatus.active
        ? AppTheme.successColor
        : assignment.status == AssignmentStatus.paused
            ? AppTheme.warningColor
            : AppTheme.textSecondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(
                routineId: routine.id,
                routineName: routine.name,
                assignmentId: assignment.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      routine.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      assignment.status == AssignmentStatus.active
                          ? 'Activa'
                          : assignment.status == AssignmentStatus.paused
                              ? 'Pausada'
                              : 'Completada',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                routine.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${DateHelpers.formatDate(assignment.startDate)} - ${DateHelpers.formatDate(assignment.endDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppTheme.textLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
