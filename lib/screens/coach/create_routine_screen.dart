import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Pantalla para crear o editar una rutina
class CreateRoutineScreen extends StatefulWidget {
  final RoutineModel? routine;

  const CreateRoutineScreen({super.key, this.routine});

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

  bool get _isEditing => widget.routine != null;

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
      level: _selectedLevel,
      durationWeeks: int.tryParse(_weeksController.text) ?? 4,
      goals: _goals,
      createdAt: _isEditing ? widget.routine!.createdAt : now,
      updatedAt: now,
    );

    bool success;
    if (_isEditing) {
      success = await routineProvider.updateRoutine(routine);
    } else {
      success = await routineProvider.createRoutine(routine);
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

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Rutina' : 'Nueva Rutina'),
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
                validator: (v) =>
                    Validators.required(v, fieldName: 'La descripción'),
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
              // Botón guardar
              CustomButton(
                text: _isEditing ? 'Actualizar Rutina' : 'Crear Rutina',
                onPressed: _saveRoutine,
                isLoading: routineProvider.isLoading,
                icon: _isEditing ? Icons.save : Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
