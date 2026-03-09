import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

/// Servicio de chat en tiempo real con Firestore
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Genera un ID de sala de chat único para dos usuarios
  String _getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Envía un mensaje a otro usuario
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final senderId = _auth.currentUser?.uid;
      if (senderId == null) throw Exception('Usuario no autenticado.');

      final newMessage = MessageModel(
        id: '',
        senderId: senderId,
        receiverId: receiverId,
        message: message.trim(),
        timestamp: DateTime.now(),
        read: false,
      );

      final chatId = _getChatId(senderId, receiverId);
      await _firestore
          .collection(Collections.messages)
          .doc(chatId)
          .collection('chats')
          .add(newMessage.toMap());
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  /// Stream de mensajes entre el usuario actual y otro usuario
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    final chatId = _getChatId(currentUserId, otherUserId);
    return _firestore
        .collection(Collections.messages)
        .doc(chatId)
        .collection('chats')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Marca un mensaje como leído
  Future<void> markAsRead(String otherUserId, String messageId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final chatId = _getChatId(currentUserId, otherUserId);
      await _firestore
          .collection(Collections.messages)
          .doc(chatId)
          .collection('chats')
          .doc(messageId)
          .update({'read': true});
    } catch (e) {
      throw Exception('Error al marcar mensaje como leído: $e');
    }
  }

  /// Obtiene la cantidad de mensajes no leídos de un usuario
  Future<int> getUnreadCount(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return 0;

      final chatId = _getChatId(currentUserId, otherUserId);
      final snapshot = await _firestore
          .collection(Collections.messages)
          .doc(chatId)
          .collection('chats')
          .where('receiverId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Marca todos los mensajes de un chat como leídos
  Future<void> markAllAsRead(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final chatId = _getChatId(currentUserId, otherUserId);
      final snapshot = await _firestore
          .collection(Collections.messages)
          .doc(chatId)
          .collection('chats')
          .where('receiverId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error al marcar mensajes como leídos: $e');
    }
  }
}
