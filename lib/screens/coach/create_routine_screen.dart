import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../models/user_model.dart';
import '../../models/workout_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/day_workouts_card.dart';

/// Pantalla para crear o editar una rutina
class CreateRoutineScreen extends StatefulWidget {
  final RoutineModel? routine;
  final UserModel? student;

  const CreateRoutineScreen({super.key, this.routine, this.student});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weeksController = TextEditingController(text: '4');
  final _goalController = TextEditingController();

  String _selectedLevel = RoutineLevels.beginner;
  List<String> _goals = [];
  DateTime? _startDate;
  DateTime? _endDate;

  // Plan semanal: día → lista de workouts (solo en memoria, guardados al final)
  final Map<String, List<WorkoutModel>> _weeklyPlan = {
    for (final day in WeekDays.ordered) day: [],
  };

  bool get _isEditing => widget.routine != null;
  bool get _hasStudent => widget.student != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final r = widget.routine!;
      _nameController.text = r.name;
      _descriptionController.text = r.description;
      _weeksController.text = r.durationWeeks.toString();
      _selectedLevel = r.level;
      _goals = List.from(r.goals);
      _startDate = r.startDate;
      _endDate = r.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weeksController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _addGoal() {
    final goal = _goalController.text.trim();
    if (goal.isNotEmpty) {
      setState(() {
        _goals.add(goal);
        _goalController.clear();
      });
    }
  }

  void _removeGoal(int index) {
    setState(() => _goals.removeAt(index));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now().add(const Duration(days: 28)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final routineProvider = context.read<RoutineProvider>();
    final now = DateTime.now();

    final routine = RoutineModel(
      id: _isEditing ? widget.routine!.id : '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      coachId: auth.currentUser!.uid,
      studentId: widget.student?.uid,
      level: _selectedLevel,
      durationWeeks: int.tryParse(_weeksController.text) ?? 4,
      goals: _goals,
      createdAt: _isEditing ? widget.routine!.createdAt : now,
      updatedAt: now,
      startDate: _startDate,
      endDate: _endDate,
    );

    String? savedId;
    bool success;

    if (_isEditing) {
      success = await routineProvider.updateRoutine(routine);
      savedId = routine.id;
    } else {
      savedId = await routineProvider.createRoutine(routine);
      success = savedId != null;
    }

    if (!mounted) return;

    if (success && savedId != null) {
      // Guardar workouts del plan semanal
      final failedCount = await _saveWeeklyWorkouts(savedId);
      if (!mounted) return;
      if (failedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$failedCount entrenamiento(s) no se pudieron guardar. Intenta nuevamente.'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Rutina actualizada exitosamente.'
              : SuccessMessages.routineCreated),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              routineProvider.errorMessage ?? ErrorMessages.genericError),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  /// Guarda los workouts del plan semanal en Firestore.
  /// Retorna el número de workouts que fallaron.
  Future<int> _saveWeeklyWorkouts(String routineId) async {
    final db = DatabaseService();
    int order = 0;
    int failedCount = 0;
    for (final entry in _weeklyPlan.entries) {
      final dayIndex = WeekDays.toIndex(entry.key);
      for (final workout in entry.value) {
        final w = workout.copyWith(
          routineId: routineId,
          dayOfWeek: dayIndex,
          order: order++,
        );
        try {
          await db.addWorkoutToRoutine(w);
        } catch (_) {
          failedCount++;
        }
      }
    }
    return failedCount;
  }

  void _addWorkoutToDay(String day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WorkoutFormSheet(
        onSave: (workout) {
          setState(() => _weeklyPlan[day]!.add(workout));
        },
      ),
    );
  }

  void _editWorkout(String day, WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WorkoutFormSheet(
        existingWorkout: workout,
        onSave: (updated) {
          setState(() {
            final list = _weeklyPlan[day]!;
            final index = list.indexOf(workout);
            if (index != -1) list[index] = updated;
          });
        },
      ),
    );
  }

  void _deleteWorkout(String day, WorkoutModel workout) {
    setState(() => _weeklyPlan[day]!.remove(workout));
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Editar Rutina'
              : _hasStudent
                  ? 'Nueva Rutina para ${widget.student!.name}'
                  : 'Nueva Rutina',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              CustomTextField(
                label: 'Nombre de la rutina',
                controller: _nameController,
                prefixIcon: Icons.fitness_center,
                validator: (v) => Validators.required(v, fieldName: 'El nombre'),
              ),
              const SizedBox(height: 16),
              // Descripción
              CustomTextField(
                label: 'Descripción',
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Duración en semanas
              CustomTextField(
                label: 'Duración (semanas)',
                controller: _weeksController,
                prefixIcon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveInt(
                  v,
                  fieldName: 'La duración',
                ),
              ),
              const SizedBox(height: 16),
              // Fechas
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Fecha de inicio',
                      date: _startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Fecha de fin',
                      date: _endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Nivel
              Text(
                'Nivel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: RoutineLevels.labels.entries.map((entry) {
                  final isSelected = _selectedLevel == entry.key;
                  final color = AppTheme.getLevelColor(entry.key);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedLevel = entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected ? color : const Color(0xFFE5E7EB),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? color : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Objetivos
              Text(
                'Objetivos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                        hintText: 'Agregar objetivo',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addGoal(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addGoal,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goals.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeGoal(entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Sección de plan semanal
              Row(
                children: [
                  const Text('📅 ', style: TextStyle(fontSize: 18)),
                  Text(
                    'Entrenamientos por día',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Organiza los entrenamientos de cada día de la semana',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...WeekDays.ordered.map((day) {
                return DayWorkoutsCard(
                  dayName: WeekDays.labels[day] ?? day,
                  workouts: _weeklyPlan[day] ?? [],
                  onAddWorkout: () => _addWorkoutToDay(day),
                  onEditWorkout: (w) => _editWorkout(day, w),
                  onDeleteWorkout: (w) => _deleteWorkout(day, w),
                );
              }),
              const SizedBox(height: 32),
              // Botón guardar
              CustomButton(
                text: _isEditing ? 'Actualizar Rutina' : 'Crear Rutina',
                onPressed: _saveRoutine,
                isLoading: routineProvider.isLoading,
                icon: _isEditing ? Icons.save : Icons.add,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Date Picker Field ────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    date != null
                        ? DateHelpers.formatDate(date!)
                        : 'Seleccionar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: date != null
                          ? AppTheme.textPrimary
                          : AppTheme.textLight,
                    ),
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

// ─── Workout Form Sheet ───────────────────────────────────────────────────────

class _WorkoutFormSheet extends StatefulWidget {
  final WorkoutModel? existingWorkout;
  final void Function(WorkoutModel) onSave;

  const _WorkoutFormSheet({this.existingWorkout, required this.onSave});

  @override
  State<_WorkoutFormSheet> createState() => _WorkoutFormSheetState();
}

class _WorkoutFormSheetState extends State<_WorkoutFormSheet> {
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _paceController = TextEditingController();
  final _seriesController = TextEditingController();
  final _restTimeController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = WorkoutTypes.continuous;
  String _intensity = Intensity.easy;

  bool get _showSeriesFields =>
      _type == WorkoutTypes.intervals || _type == WorkoutTypes.series;

  @override
  void initState() {
    super.initState();
    final w = widget.existingWorkout;
    if (w != null) {
      _nameController.text = w.name;
      _distanceController.text = w.distance > 0 ? w.distance.toString() : '';
      _durationController.text = w.duration > 0 ? w.duration.toString() : '';
      _paceController.text = w.pace;
      _seriesController.text = w.series?.toString() ?? '';
      _restTimeController.text = w.restTime?.toString() ?? '';
      _notesController.text = w.notes ?? '';
      _type = w.type;
      _intensity = w.intensity;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _paceController.dispose();
    _seriesController.dispose();
    _restTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del entrenamiento es requerido.')),
      );
      return;
    }

    final workout = WorkoutModel(
      id: widget.existingWorkout?.id ?? '',
      routineId: widget.existingWorkout?.routineId ?? '',
      name: _nameController.text.trim(),
      type: _type,
      description: '',
      distance: double.tryParse(_distanceController.text) ?? 0,
      duration: int.tryParse(_durationController.text) ?? 0,
      pace: _paceController.text.trim(),
      dayOfWeek: widget.existingWorkout?.dayOfWeek ?? 0,
      order: widget.existingWorkout?.order ?? 0,
      intensity: _intensity,
      series: _showSeriesFields
          ? int.tryParse(_seriesController.text)
          : null,
      restTime: _showSeriesFields
          ? int.tryParse(_restTimeController.text)
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    widget.onSave(workout);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existingWorkout != null
                        ? 'Editar entrenamiento'
                        : 'Agregar entrenamiento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Nombre
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del entrenamiento *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_run),
              ),
            ),
            const SizedBox(height: 16),
            // Tipo
            _buildDropdown(
              label: 'Tipo de entrenamiento',
              value: _type,
              items: WorkoutTypes.labels,
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            // Intensidad
            _buildDropdown(
              label: 'Intensidad',
              value: _intensity,
              items: Intensity.labels,
              onChanged: (v) => setState(() => _intensity = v!),
            ),
            const SizedBox(height: 16),
            // Distancia y duración
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _distanceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Distancia (km)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duración (min)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ritmo
            TextField(
              controller: _paceController,
              decoration: const InputDecoration(
                labelText: 'Ritmo objetivo (ej: 5:30)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
            ),
            // Series y descanso (condicional)
            if (_showSeriesFields) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _seriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Series',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _restTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Descanso (seg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.hourglass_empty),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Notas
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas adicionales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      widget.existingWorkout != null ? 'Actualizar' : 'Agregar',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
