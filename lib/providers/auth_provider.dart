import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Provider de autenticación para Running Coach App
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Escuchar cambios en el estado de autenticación
    _authService.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Callback cuando cambia el estado de autenticación
  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await loadCurrentUser();
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Carga los datos del usuario actual desde Firestore
  Future<void> loadCurrentUser() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }
      _currentUser = await _databaseService.getUser(user.uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Inicia sesión con email y contraseña
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signIn(email, password);
      await loadCurrentUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> signUp(
    String email,
    String password,
    String name,
    String role, {
    String? coachId,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signUp(
        email,
        password,
        name,
        role,
        coachId: coachId,
      );
      await loadCurrentUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Envía email para restablecer contraseña
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
