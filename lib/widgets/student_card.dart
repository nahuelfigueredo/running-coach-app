import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

/// Card reutilizable para mostrar información de un alumno en listas del coach
class StudentCard extends StatelessWidget {
  final UserModel student;
  final VoidCallback onTap;
  final Widget? trailing;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con ícono de corredor
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                backgroundImage: student.profileImage != null
                    ? NetworkImage(student.profileImage!)
                    : null,
                child: student.profileImage == null
                    ? const Icon(
                        Icons.directions_run,
                        color: AppTheme.primaryColor,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Información del alumno
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Trailing: flecha o widget personalizado
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
