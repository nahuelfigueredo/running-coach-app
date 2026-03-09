import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Servicio de autenticación con Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicia sesión con email y contraseña
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(ErrorMessages.genericError);
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  Future<UserCredential?> signUp(
    String email,
    String password,
    String name,
    String role, {
    String? coachId,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Crear el perfil del usuario en Firestore
      if (credential.user != null) {
        final user = UserModel(
          uid: credential.user!.uid,
          email: email.trim(),
          name: name.trim(),
          role: role,
          coachId: coachId,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(Collections.users)
            .doc(credential.user!.uid)
            .set(user.toMap());
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(ErrorMessages.genericError);
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(ErrorMessages.genericError);
    }
  }

  /// Envía un correo para restablecer la contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(ErrorMessages.genericError);
    }
  }

  /// Retorna el usuario actualmente autenticado
  User? getCurrentUser() => _auth.currentUser;

  /// Stream que emite cambios en el estado de autenticación
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Maneja las excepciones de FirebaseAuth y retorna mensajes amigables
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception(ErrorMessages.userNotFound);
      case 'wrong-password':
        return Exception(ErrorMessages.wrongPassword);
      case 'email-already-in-use':
        return Exception(ErrorMessages.emailInUse);
      case 'invalid-email':
        return Exception('El formato del email no es válido.');
      case 'weak-password':
        return Exception('La contraseña es demasiado débil.');
      case 'user-disabled':
        return Exception('Esta cuenta ha sido deshabilitada.');
      case 'too-many-requests':
        return Exception('Demasiados intentos. Intenta más tarde.');
      default:
        return Exception(e.message ?? ErrorMessages.authError);
    }
  }
}
