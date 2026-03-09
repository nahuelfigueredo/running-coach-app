import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Card para mostrar un workout individual
class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final String? status; // 'pending' | 'completed' | 'skipped'
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.status,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.getWorkoutTypeColor(workout.type);
    final typeLabel = WorkoutTypes.labels[workout.type] ?? workout.type;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de tipo
              Container(
                width: 4,
                height: 70,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              // Información del workout
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workout.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (workout.distance > 0)
                          _metricChip(
                            Icons.straighten,
                            '${workout.distance.toStringAsFixed(1)} km',
                          ),
                        if (workout.distance > 0) const SizedBox(width: 8),
                        if (workout.duration > 0)
                          _metricChip(
                            Icons.timer,
                            '${workout.duration} min',
                          ),
                        if (workout.duration > 0) const SizedBox(width: 8),
                        if (workout.pace.isNotEmpty)
                          _metricChip(
                            Icons.speed,
                            workout.pace,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botón de completar
              if (onComplete != null && status == SessionStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline),
                    color: AppTheme.successColor,
                    tooltip: 'Marcar completado',
                  ),
                ),
              if (status == SessionStatus.completed)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (status == null) return const SizedBox.shrink();

    Color color;
    String label;

    switch (status) {
      case SessionStatus.completed:
        color = AppTheme.successColor;
        label = 'Completado';
        break;
      case SessionStatus.skipped:
        color = AppTheme.errorColor;
        label = 'Omitido';
        break;
      default:
        color = AppTheme.warningColor;
        label = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _metricChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
