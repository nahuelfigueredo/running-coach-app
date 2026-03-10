import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../utils/theme.dart';

/// Item individual de entrenamiento para mostrar en listas del planificador
class WorkoutItem extends StatelessWidget {
  static const int _defaultRestTimeSeconds = 60;

  final WorkoutModel workout;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkoutItem({
    super.key,
    required this.workout,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.getWorkoutTypeColor(workout.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.08),
        border: Border.all(color: typeColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono de tipo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.directions_run, color: typeColor, size: 18),
            ),
            const SizedBox(width: 10),
            // Detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (workout.distance > 0)
                        _DetailChip(
                          label: '${workout.distance.toStringAsFixed(1)} km',
                          icon: Icons.straighten,
                        ),
                      if (workout.duration > 0)
                        _DetailChip(
                          label: '${workout.duration} min',
                          icon: Icons.timer_outlined,
                        ),
                      if (workout.pace.isNotEmpty)
                        _DetailChip(
                          label: '${workout.pace} min/km',
                          icon: Icons.speed,
                        ),
                      _IntensityChip(intensity: workout.intensity),
                    ],
                  ),
                  if (workout.series != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${workout.series} series · '
                        '${workout.restTime ?? WorkoutItem._defaultRestTimeSeconds}s descanso',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (workout.notes != null && workout.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        workout.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Acciones
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  color: AppTheme.primaryColor,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Editar',
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  color: AppTheme.errorColor,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _DetailChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _IntensityChip extends StatelessWidget {
  final String intensity;

  const _IntensityChip({required this.intensity});

  Color get _color {
    switch (intensity) {
      case 'easy':
        return AppTheme.beginnerColor;
      case 'moderate':
        return AppTheme.intermediateColor;
      case 'hard':
        return AppTheme.advancedColor;
      case 'maximum':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _label {
    switch (intensity) {
      case 'easy':
        return 'Suave';
      case 'moderate':
        return 'Moderado';
      case 'hard':
        return 'Intenso';
      case 'maximum':
        return 'Máximo';
      default:
        return intensity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
