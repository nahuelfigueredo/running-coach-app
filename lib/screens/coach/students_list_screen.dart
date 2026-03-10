import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';
import '../../widgets/student_card.dart';
import 'student_detail_screen.dart';

/// Lista de alumnos del coach
class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  List<UserModel> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser == null) return;
      final db = DatabaseService();
      _students = await db.getStudentsByCoach(auth.currentUser!.uid);
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
        title: const Text('Mis Alumnos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: 'Actualizar',
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
            ElevatedButton(
              onPressed: _loadStudents,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_students.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 72, color: AppTheme.textLight),
            SizedBox(height: 16),
            Text(
              'Aún no tienes alumnos asignados',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return StudentCard(
          student: student,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailScreen(student: student),
            ),
          ),
        );
      },
    );
  }
}
