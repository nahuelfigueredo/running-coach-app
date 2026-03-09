import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/assignment_model.dart';
import '../../models/routine_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';

/// Pantalla para asignar una rutina a un alumno
class AssignRoutineScreen extends StatefulWidget {
  const AssignRoutineScreen({super.key});

  @override
  State<AssignRoutineScreen> createState() => _AssignRoutineScreenState();
}

class _AssignRoutineScreenState extends State<AssignRoutineScreen> {
  final DatabaseService _db = DatabaseService();

  RoutineModel? _selectedRoutine;
  UserModel? _selectedStudent;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<UserModel> _students = [];
  bool _isLoading = false;
  bool _loadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final routineProvider = context.read<RoutineProvider>();

    if (auth.currentUser == null) return;

    // Cargar alumnos y rutinas
    try {
      _students = await _db.getStudentsByCoach(auth.currentUser!.uid);
      if (routineProvider.routines.isEmpty) {
        await routineProvider.loadRoutines(auth.currentUser!.uid);
      }
    } catch (_) {}

    if (mounted) setState(() => _loadingStudents = false);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _assignRoutine() async {
    if (_selectedRoutine == null) {
      _showError('Por favor selecciona una rutina.');
      return;
    }
    if (_selectedStudent == null) {
      _showError('Por favor selecciona un alumno.');
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      _showError('La fecha de fin debe ser posterior a la de inicio.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final assignment = AssignmentModel(
        id: '',
        routineId: _selectedRoutine!.id,
        studentId: _selectedStudent!.uid,
        coachId: auth.currentUser!.uid,
        startDate: _startDate,
        endDate: _endDate,
        status: AssignmentStatus.active,
        assignedAt: DateTime.now(),
      );

      await _db.assignRoutine(assignment);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(SuccessMessages.routineAssigned),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Rutina')),
      body: _loadingStudents
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona la rutina',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<RoutineModel>(
                    value: _selectedRoutine,
                    hint: 'Selecciona una rutina',
                    items: routineProvider.routines,
                    labelBuilder: (r) => r.name,
                    onChanged: (v) => setState(() => _selectedRoutine = v),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Selecciona el alumno',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _students.isEmpty
                      ? const Text(
                          'No tienes alumnos registrados.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        )
                      : _buildDropdown<UserModel>(
                          value: _selectedStudent,
                          hint: 'Selecciona un alumno',
                          items: _students,
                          labelBuilder: (s) => s.name,
                          onChanged: (v) =>
                              setState(() => _selectedStudent = v),
                        ),
                  const SizedBox(height: 24),
                  Text(
                    'Período',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'Inicio',
                          date: _startDate,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'Fin',
                          date: _endDate,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Asignar Rutina',
                    onPressed: _assignRoutine,
                    isLoading: _isLoading,
                    icon: Icons.assignment_turned_in,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
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
            const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Column(
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
                  DateHelpers.formatDate(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
