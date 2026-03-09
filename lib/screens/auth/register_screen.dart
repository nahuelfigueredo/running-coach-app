import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Pantalla de registro de nuevo usuario
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = Roles.student;
  String? _selectedCoachId;
  List<UserModel> _coaches = [];
  bool _loadingCoaches = false;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCoaches() async {
    setState(() => _loadingCoaches = true);
    try {
      final db = DatabaseService();
      _coaches = await db.getUsersByRole(Roles.coach);
    } catch (_) {
      _coaches = [];
    } finally {
      if (mounted) setState(() => _loadingCoaches = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que un estudiante haya seleccionado coach
    if (_selectedRole == Roles.student && _selectedCoachId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un coach.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _selectedRole,
      coachId: _selectedRole == Roles.student ? _selectedCoachId : null,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? ErrorMessages.genericError),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Únete a Running Coach',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa el formulario para crear tu cuenta',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                // Nombre
                CustomTextField(
                  label: 'Nombre completo',
                  controller: _nameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (v) => Validators.required(v, fieldName: 'El nombre'),
                ),
                const SizedBox(height: 16),
                // Email
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                // Contraseña
                CustomTextField(
                  label: 'Contraseña',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.password,
                ),
                const SizedBox(height: 24),
                // Selector de rol
                Text(
                  'Soy...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _roleOption(
                        context,
                        role: Roles.coach,
                        label: 'Profesor',
                        icon: Icons.sports,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _roleOption(
                        context,
                        role: Roles.student,
                        label: 'Alumno',
                        icon: Icons.directions_run,
                      ),
                    ),
                  ],
                ),
                // Selector de coach (solo para alumnos)
                if (_selectedRole == Roles.student) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Selecciona tu coach',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_loadingCoaches)
                    const Center(child: CircularProgressIndicator())
                  else if (_coaches.isEmpty)
                    const Text(
                      'No hay coaches disponibles por el momento.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCoachId,
                          hint: const Text('Selecciona un coach'),
                          items: _coaches
                              .map(
                                (coach) => DropdownMenuItem(
                                  value: coach.uid,
                                  child: Text(coach.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedCoachId = value);
                          },
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 32),
                // Botón de registro
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => CustomButton(
                    text: 'Crear Cuenta',
                    onPressed: _register,
                    isLoading: auth.isLoading,
                    icon: Icons.person_add,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Iniciar sesión'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleOption(
    BuildContext context, {
    required String role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _selectedCoachId = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
