import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

/// Provider de chat para Running Coach App
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Obtiene el stream de mensajes con otro usuario
  Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
    return _chatService.getMessages(otherUserId);
  }

  /// Envía un mensaje a otro usuario
  Future<bool> sendMessage(String receiverId, String message) async {
    if (message.trim().isEmpty) return false;
    _errorMessage = null;
    try {
      await _chatService.sendMessage(receiverId, message);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Marca todos los mensajes de un chat como leídos
  Future<void> markAllAsRead(String otherUserId) async {
    try {
      await _chatService.markAllAsRead(otherUserId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Obtiene el conteo de mensajes no leídos
  Future<int> getUnreadCount(String otherUserId) async {
    return _chatService.getUnreadCount(otherUserId);
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
