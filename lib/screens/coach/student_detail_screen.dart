import 'package:flutter/material.dart';
import '../../models/routine_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../utils/date_helpers.dart';
import '../../utils/theme.dart';
import 'create_routine_screen.dart';

/// Pantalla de detalle de un alumno: muestra su información, rutinas y progreso
class StudentDetailScreen extends StatefulWidget {
  final UserModel student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final DatabaseService _db = DatabaseService();

  List<RoutineModel> _routines = [];
  Map<String, dynamic> _stats = {};
  bool _isLoadingRoutines = true;
  bool _isLoadingStats = true;
  String? _errorRoutines;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadRoutines(), _loadStats()]);
  }

  Future<void> _loadRoutines() async {
    setState(() {
      _isLoadingRoutines = true;
      _errorRoutines = null;
    });
    try {
      _routines = await _db.getRoutinesByStudent(widget.student.uid);
    } catch (e) {
      _errorRoutines = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoadingRoutines = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      _stats = await _db.getStudentStatistics(widget.student.uid);
    } catch (_) {
      _stats = {};
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateRoutine,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Rutina'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StudentInfoCard(student: widget.student),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildRoutinesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }
    final totalSessions = _stats['totalSessions'] as int? ?? 0;
    final totalDistance = (_stats['totalDistance'] as double?) ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatItem(
            label: 'Sesiones',
            value: '$totalSessions',
            icon: Icons.calendar_today_outlined,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            label: 'Rutinas',
            value: '${_routines.length}',
            icon: Icons.fitness_center_outlined,
            color: AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            label: 'Km totales',
            value: totalDistance.toStringAsFixed(1),
            icon: Icons.directions_run,
            color: AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rutinas Asignadas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (_isLoadingRoutines)
          const Center(child: CircularProgressIndicator())
        else if (_errorRoutines != null)
          _ErrorWidget(message: _errorRoutines!, onRetry: _loadRoutines)
        else if (_routines.isEmpty)
          _EmptyRoutinesWidget(onAdd: _navigateToCreateRoutine)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _routines.length,
            itemBuilder: (context, index) {
              return _RoutineCard(routine: _routines[index]);
            },
          ),
      ],
    );
  }

  Future<void> _navigateToCreateRoutine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRoutineScreen(student: widget.student),
      ),
    );
    // Reload routines after returning
    _loadRoutines();
  }
}

// ─── Widgets privados ────────────────────────────────────────────────────────

class _StudentInfoCard extends StatelessWidget {
  final UserModel student;

  const _StudentInfoCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
              backgroundImage: student.profileImage != null
                  ? NetworkImage(student.profileImage!)
                  : null,
              child: student.profileImage == null
                  ? const Icon(
                      Icons.directions_run,
                      size: 38,
                      color: AppTheme.primaryColor,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Desde ${DateHelpers.formatDateShort(student.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final RoutineModel routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        routine.isActive ? AppTheme.successColor : AppTheme.textSecondary;
    final statusLabel = routine.isActive ? 'Activa' : 'Inactiva';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (routine.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                routine.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  routine.startDate != null
                      ? 'Inicio: ${DateHelpers.formatDateShort(routine.startDate!)}'
                      : '${routine.durationWeeks} semanas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (routine.endDate != null) ...[
                  const Text(' · '),
                  Text(
                    'Fin: ${DateHelpers.formatDateShort(routine.endDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutinesWidget extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyRoutinesWidget({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.fitness_center_outlined,
              size: 64, color: AppTheme.textLight),
          const SizedBox(height: 12),
          const Text(
            'No hay rutinas asignadas',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Crear primera rutina'),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppTheme.errorColor),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
