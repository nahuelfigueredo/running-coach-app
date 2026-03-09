import 'package:intl/intl.dart';

/// Helpers para manejo de fechas en la aplicación Running Coach App

class DateHelpers {
  /// Formatea una fecha como "dd/MM/yyyy"
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea una fecha como "dd MMM yyyy" (ej: "15 Mar 2024")
  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  /// Formatea una fecha y hora como "dd/MM/yyyy HH:mm"
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formatea solo la hora como "HH:mm"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Formatea como "hace X tiempo" relativo
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} días';
    } else {
      return formatDate(date);
    }
  }

  /// Obtiene el inicio de la semana (lunes) para una fecha dada
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday; // 1 = lunes, 7 = domingo
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Obtiene el fin de la semana (domingo) para una fecha dada
  static DateTime endOfWeek(DateTime date) {
    final start = startOfWeek(date);
    return start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  /// Obtiene el inicio del mes para una fecha dada
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Obtiene el fin del mes para una fecha dada
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Compara si dos fechas son el mismo día
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Verifica si una fecha es hoy
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Verifica si una fecha es en el pasado (antes de hoy)
  static bool isPast(DateTime date) {
    final today = DateTime.now();
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  /// Obtiene el nombre del día de la semana en español
  static String weekDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[(weekday - 1) % 7];
  }

  /// Obtiene el nombre del mes en español
  static String monthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[(month - 1) % 12];
  }

  /// Calcula la cantidad de días entre dos fechas
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }

  /// Obtiene las fechas de los últimos N meses
  static List<DateTime> lastNMonths(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      final month = now.month - i;
      final year = now.year + (month - 1) ~/ 12;
      return DateTime(year, ((month - 1) % 12) + 1, 1);
    }).reversed.toList();
  }
}
