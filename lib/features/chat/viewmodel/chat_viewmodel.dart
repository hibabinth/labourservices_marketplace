import 'package:flutter/material.dart';
import '../repository/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository repository;

  ChatViewModel({required this.repository});

  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> userChats = [];
  List<Map<String, dynamic>> workerChats = [];

  Future<void> loadUserChats() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      userChats = await repository.getUserChats();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD USER CHATS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkerChats() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      workerChats = await repository.getWorkerChats();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD WORKER CHATS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
