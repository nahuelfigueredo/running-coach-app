import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/training_session_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_helpers.dart';
import '../../utils/theme.dart';

/// Pantalla de calendario con sesiones de entrenamiento
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TrainingSessionModel>> _eventsByDay = {};
  List<TrainingSessionModel> _allSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    try {
      final db = DatabaseService();
      _allSessions = await db.getSessionsByStudent(auth.currentUser!.uid);
      _buildEventMap();
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _buildEventMap() {
    _eventsByDay = {};
    for (final session in _allSessions) {
      final day = DateTime(
        session.scheduledDate.year,
        session.scheduledDate.month,
        session.scheduledDate.day,
      );
      _eventsByDay[day] = [...(_eventsByDay[day] ?? []), session];
    }
  }

  List<TrainingSessionModel> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsByDay[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendario
                Card(
                  margin: const EdgeInsets.all(12),
                  child: TableCalendar<TrainingSessionModel>(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    eventLoader: _getEventsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppTheme.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                    ),
                  ),
                ),
                // Lista de eventos del día seleccionado
                Expanded(
                  child: _buildEventsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildEventsList() {
    if (_selectedDay == null) {
      return const Center(child: Text('Selecciona un día'));
    }

    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_available, size: 48, color: AppTheme.textLight),
            const SizedBox(height: 8),
            Text(
              'Sin entrenamientos el ${DateHelpers.formatDateShort(_selectedDay!)}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final session = events[index];
        final isCompleted = session.status == SessionStatus.completed;
        final isSkipped = session.status == SessionStatus.skipped;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCompleted
                  ? AppTheme.successColor.withOpacity(0.15)
                  : isSkipped
                      ? AppTheme.errorColor.withOpacity(0.15)
                      : AppTheme.warningColor.withOpacity(0.15),
              child: Icon(
                isCompleted
                    ? Icons.check
                    : isSkipped
                        ? Icons.close
                        : Icons.run_circle_outlined,
                color: isCompleted
                    ? AppTheme.successColor
                    : isSkipped
                        ? AppTheme.errorColor
                        : AppTheme.warningColor,
              ),
            ),
            title: Text('Entrenamiento ${index + 1}'),
            subtitle: Text(
              isCompleted
                  ? 'Completado'
                  : isSkipped
                      ? 'Omitido'
                      : 'Pendiente',
            ),
          ),
        );
      },
    );
  }
}
