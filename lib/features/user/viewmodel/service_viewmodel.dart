import 'package:flutter/material.dart';
import '../repository/service_repository.dart';

class ServiceViewModel extends ChangeNotifier {
  final ServiceRepository repository;

  ServiceViewModel({required this.repository});

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> topWorkers = [];
  List<Map<String, dynamic>> searchResults = [];
  Map<String, dynamic>? selectedWorker;

  Future<void> loadTopWorkers() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      topWorkers = await repository.getTopWorkers();
      debugPrint('TOP WORKERS => $topWorkers');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD TOP WORKERS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchWorkers({String? searchText, String? category}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      searchResults = await repository.searchWorkers(
        searchText: searchText,
        category: category,
      );
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('SEARCH WORKERS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkerDetails(String workerId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      selectedWorker = await repository.getWorkerById(workerId);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD WORKER DETAILS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedWorker() {
    selectedWorker = null;
    notifyListeners();
  }
}
