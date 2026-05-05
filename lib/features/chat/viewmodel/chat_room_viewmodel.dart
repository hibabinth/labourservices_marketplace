import 'dart:async';
import 'package:flutter/material.dart';
import '../repository/chat_repository.dart';

class ChatRoomViewModel extends ChangeNotifier {
  final ChatRepository repository;

  ChatRoomViewModel({required this.repository});

  bool isLoading = false;
  bool isSending = false;
  String? errorMessage;
  List<Map<String, dynamic>> messages = [];
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSubscription;

  String? get currentUserId => repository.currentUserId;

  Future<void> loadMessages(String chatId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      messages = await repository.getMessages(chatId);
      await repository.markMessagesAsSeen(chatId);
      messages = await repository.getMessages(chatId);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD CHAT MESSAGES ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> subscribeToMessages(String chatId) async {
    await _messagesSubscription?.cancel();

    _messagesSubscription = repository
        .streamMessages(chatId)
        .listen(
          (liveMessages) async {
            messages = liveMessages;
            notifyListeners();

            await repository.markMessagesAsSeen(chatId);
            messages = await repository.getMessages(chatId);
            notifyListeners();
          },
          onError: (error) {
            errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> markSeenAndRefresh(String chatId) async {
    try {
      await repository.markMessagesAsSeen(chatId);
      messages = await repository.getMessages(chatId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('MARK SEEN ERROR => $e');
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      isSending = true;
      errorMessage = null;
      notifyListeners();

      await repository.sendMessage(chatId: chatId, message: message);
      messages = await repository.getMessages(chatId);
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('SEND CHAT MESSAGE ERROR => $e');
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<bool> updateMessage({
    required String chatId,
    required String messageId,
    required String newMessage,
  }) async {
    try {
      errorMessage = null;
      notifyListeners();

      await repository.updateMessage(
        messageId: messageId,
        newMessage: newMessage,
      );

      messages = await repository.getMessages(chatId);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('UPDATE CHAT MESSAGE ERROR => $e');
      return false;
    }
  }

  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      errorMessage = null;
      notifyListeners();

      await repository.deleteMessage(messageId);
      messages = await repository.getMessages(chatId);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('DELETE CHAT MESSAGE ERROR => $e');
      return false;
    }
  }

  Future<void> disposeSubscription() async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
