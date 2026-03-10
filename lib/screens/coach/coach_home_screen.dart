import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';
import '../../widgets/stats_card.dart';
import 'students_list_screen.dart';
import 'create_routine_screen.dart';

/// Dashboard principal del coach con navegación por pestañas
class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final coach = auth.currentUser;

    final pages = [
      _CoachDashboard(coachName: coach?.name ?? 'Coach', coachId: coach?.uid ?? ''),
      const StudentsListScreen(),
      const _RoutinesTab(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Alumnos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
        ],
      ),
    );
  }
}

/// Dashboard principal del coach
class _CoachDashboard extends StatefulWidget {
  final String coachName;
  final String coachId;

  const _CoachDashboard({required this.coachName, required this.coachId});

  @override
  State<_CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<_CoachDashboard> {
  final _db = DatabaseService();
  int _studentCount = 0;
  int _routineCount = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final students = await _db.getStudentsByCoach(widget.coachId);
      final routines = await _db.getRoutinesByCoach(widget.coachId);
      if (mounted) {
        setState(() {
          _studentCount = students.length;
          _routineCount = routines.length;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Running Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context, auth),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo personalizado
            Text(
              '¡Hola, ${widget.coachName}! 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Gestiona tus alumnos y rutinas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // Estadísticas
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (_loadingStats)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Alumnos',
                      value: '$_studentCount',
                      icon: Icons.people,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Rutinas',
                      value: '$_routineCount',
                      icon: Icons.fitness_center,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            // Accesos rápidos
            Text(
              'Acciones rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'Nueva rutina',
                    color: AppTheme.primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateRoutineScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.chat_bubble_outline,
                    label: 'Mensajes',
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona un alumno para chatear.'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await auth.signOut();
    }
  }
}

/// Tab de rutinas del coach
class _RoutinesTab extends StatefulWidget {
  const _RoutinesTab();

  @override
  State<_RoutinesTab> createState() => _RoutinesTabState();
}

class _RoutinesTabState extends State<_RoutinesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<RoutineProvider>().loadRoutines(auth.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Mis Rutinas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
        ).then((_) {
          final auth = context.read<AuthProvider>();
          if (auth.currentUser != null) {
            context.read<RoutineProvider>().loadRoutines(auth.currentUser!.uid);
          }
        }),
        child: const Icon(Icons.add),
      ),
      body: routineProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : routineProvider.routines.isEmpty
              ? const Center(
                  child: Text('No tienes rutinas creadas aún.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: routineProvider.routines.length,
                  itemBuilder: (context, index) {
                    final routine = routineProvider.routines[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(routine.name),
                        subtitle: Text('${routine.durationWeeks} semanas · ${routine.level}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    );
                  },
                ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
