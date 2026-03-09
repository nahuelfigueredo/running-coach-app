/// Validadores de formularios para la aplicación Running Coach App

class Validators {
  /// Valida un email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido.';
    }
    return null;
  }

  /// Valida una contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida.';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  /// Valida que un campo no esté vacío
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido.';
    }
    return null;
  }

  /// Valida un número entero positivo
  static String? positiveInt(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '${fieldName ?? 'El valor'} debe ser un número entero positivo.';
    }
    return null;
  }

  /// Valida un número decimal positivo
  static String? positiveDouble(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '${fieldName ?? 'El valor'} debe ser un número positivo.';
    }
    return null;
  }

  /// Valida el formato de pace (ej: "5:30")
  static String? pace(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // pace es opcional
    }
    final paceRegex = RegExp(r'^\d{1,2}:\d{2}$');
    if (!paceRegex.hasMatch(value.trim())) {
      return 'Formato de pace inválido. Usa MM:SS (ej: 5:30).';
    }
    final parts = value.trim().split(':');
    final seconds = int.tryParse(parts[1]);
    if (seconds == null || seconds >= 60) {
      return 'Los segundos deben ser menores a 60.';
    }
    return null;
  }

  /// Valida que las contraseñas coincidan
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña.';
    }
    if (value != original) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  /// Valida un número de teléfono
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // teléfono es opcional
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un teléfono válido.';
    }
    return null;
  }
}
