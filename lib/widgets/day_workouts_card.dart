import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../utils/theme.dart';
import 'workout_item.dart';

/// Card expandible para cada día de la semana en el planificador de rutinas
class DayWorkoutsCard extends StatefulWidget {
  final String dayName;
  final List<WorkoutModel> workouts;
  final VoidCallback onAddWorkout;
  final Function(WorkoutModel) onEditWorkout;
  final Function(WorkoutModel) onDeleteWorkout;

  const DayWorkoutsCard({
    super.key,
    required this.dayName,
    required this.workouts,
    required this.onAddWorkout,
    required this.onEditWorkout,
    required this.onDeleteWorkout,
  });

  @override
  State<DayWorkoutsCard> createState() => _DayWorkoutsCardState();
}

class _DayWorkoutsCardState extends State<DayWorkoutsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasWorkouts = widget.workouts.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // Header del día
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Indicador de contenido
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: hasWorkouts
                          ? AppTheme.primaryColor
                          : AppTheme.textLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.dayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  // Cantidad de entrenamientos
                  if (hasWorkouts)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.workouts.length}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Contenido expandido
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Lista de entrenamientos
                  ...widget.workouts.map(
                    (workout) => WorkoutItem(
                      workout: workout,
                      onEdit: () => widget.onEditWorkout(workout),
                      onDelete: () => widget.onDeleteWorkout(workout),
                    ),
                  ),
                  // Botón agregar entrenamiento
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onAddWorkout,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar entrenamiento'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Si no está expandido y no hay workouts, mostrar botón pequeño
          if (!_expanded && !hasWorkouts)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _expanded = true);
                    widget.onAddWorkout();
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar entrenamiento'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
