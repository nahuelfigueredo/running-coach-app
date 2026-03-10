import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      if (kDebugMode) {
        print('🔐 AuthService.signUp iniciado');
        print('  Email: $email');
        print('  Rol: $role');
        if (coachId != null) {
          print('  Coach ID: $coachId');
        }
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (kDebugMode) {
        print('✅ Usuario creado en Firebase Auth: ${credential.user?.uid}');
      }

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

        if (kDebugMode) {
          print('💾 Guardando usuario en Firestore...');
        }
        await _firestore
            .collection(Collections.users)
            .doc(credential.user!.uid)
            .set(user.toMap());
        if (kDebugMode) {
          print('✅ Usuario guardado en Firestore exitosamente');
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error genérico en signUp: $e');
        print('Stack trace: $stackTrace');
      }
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
    if (kDebugMode) {
      print('🔴 Manejando error de Firebase: ${e.code}');
    }
    switch (e.code) {
      case 'user-not-found':
        return Exception(ErrorMessages.userNotFound);
      case 'wrong-password':
        return Exception(ErrorMessages.wrongPassword);
      case 'email-already-in-use':
        return Exception('Este email ya está registrado. Intenta iniciar sesión.');
      case 'invalid-email':
        return Exception('El formato del email no es válido.');
      case 'weak-password':
        return Exception('La contraseña debe tener al menos 6 caracteres.');
      case 'user-disabled':
        return Exception('Esta cuenta ha sido deshabilitada.');
      case 'too-many-requests':
        return Exception('Demasiados intentos. Intenta más tarde.');
      case 'operation-not-allowed':
        return Exception('El registro con email/contraseña no está habilitado en Firebase.');
      case 'invalid-credential':
        return Exception('Las credenciales proporcionadas no son válidas.');
      default:
        return Exception('${e.message ?? ErrorMessages.authError} (código: ${e.code})');
    }
  }
}
