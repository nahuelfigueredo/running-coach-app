import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/training_session_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';
import '../../utils/theme.dart';

/// Pantalla de estadísticas del alumno con gráficos
class MyStatisticsScreen extends StatefulWidget {
  const MyStatisticsScreen({super.key});

  @override
  State<MyStatisticsScreen> createState() => _MyStatisticsScreenState();
}

class _MyStatisticsScreenState extends State<MyStatisticsScreen> {
  Map<String, dynamic> _stats = {};
  List<TrainingSessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    try {
      final db = DatabaseService();
      final stats = await db.getStudentStatistics(auth.currentUser!.uid);
      final sessions = await db.getSessionsByStudent(auth.currentUser!.uid);
      setState(() {
        _stats = stats;
        _sessions = sessions;
      });
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  /// Calcula la racha actual de entrenamientos consecutivos completados
  int get _currentStreak {
    final completed = _sessions
        .where((s) => s.status == SessionStatus.completed)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    if (completed.isEmpty) return 0;

    int streak = 0;
    DateTime? prevDate;

    for (final session in completed) {
      if (prevDate == null) {
        prevDate = session.scheduledDate;
        streak = 1;
      } else {
        final diff = DateHelpers.daysBetween(
            session.scheduledDate, prevDate);
        if (diff <= 1) {
          streak++;
          prevDate = session.scheduledDate;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  /// Construye datos para el gráfico de barras mensual
  List<BarChartGroupData> _buildBarData() {
    final months = DateHelpers.lastNMonths(6);
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final count = _sessions.where((s) {
        return s.status == SessionStatus.completed &&
            s.scheduledDate.year == month.year &&
            s.scheduledDate.month == month.month;
      }).length;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: AppTheme.primaryColor,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjetas de estadísticas
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle,
                          label: 'Completados',
                          value:
                              '${_stats['totalSessions'] ?? 0}',
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department,
                          label: 'Racha',
                          value: '$_currentStreak días',
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.straighten,
                          label: 'Distancia total',
                          value:
                              '${((_stats['totalDistance'] ?? 0.0) as double).toStringAsFixed(1)} km',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.timer,
                          label: 'Tiempo total',
                          value:
                              '${_stats['totalDuration'] ?? 0} min',
                          color: AppTheme.fartlekColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Gráfico de progreso mensual
                  Text(
                    'Entrenamientos por mes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: _buildBarChart(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBarChart() {
    final barData = _buildBarData();
    final months = DateHelpers.lastNMonths(6);

    if (barData.every((g) => g.barRods.first.toY == 0)) {
      return const Center(
        child: Text(
          'Sin datos de entrenamientos aún',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barData,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= months.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  DateHelpers.monthName(months[index].month).substring(0, 3),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
