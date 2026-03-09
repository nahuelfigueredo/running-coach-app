import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Card para mostrar una rutina de entrenamiento
class RoutineCard extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAssign;

  const RoutineCard({
    super.key,
    required this.routine,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.getLevelColor(routine.level);
    final levelLabel = RoutineLevels.labels[routine.level] ?? routine.level;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      levelLabel,
                      style: TextStyle(
                        color: levelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                routine.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoChip(
                    context,
                    Icons.calendar_today,
                    '${routine.durationWeeks} semanas',
                  ),
                  const SizedBox(width: 8),
                  _infoChip(
                    context,
                    Icons.flag,
                    '${routine.goals.length} objetivos',
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null || onAssign != null) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onAssign != null)
                      TextButton.icon(
                        onPressed: onAssign,
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Asignar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Editar',
                        color: AppTheme.primaryColor,
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        tooltip: 'Eliminar',
                        color: AppTheme.errorColor,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
