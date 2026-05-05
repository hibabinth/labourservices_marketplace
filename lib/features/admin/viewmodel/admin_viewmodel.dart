import 'package:flutter/material.dart';
import '../repository/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository repository;

  AdminViewModel({required this.repository});

  bool isLoading = false;
  String? errorMessage;

  int totalUsers = 0;
  int totalWorkers = 0;
  int totalBookings = 0;
  int pendingBookings = 0;
  int completedBookings = 0;
  int incompleteWorkerProfiles = 0;

  List<Map<String, dynamic>> recentBookings = [];
  List<Map<String, dynamic>> recentWorkers = [];

  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      totalUsers = await repository.getTotalUsersCount();
      totalWorkers = await repository.getTotalWorkersCount();
      totalBookings = await repository.getTotalBookingsCount();
      pendingBookings = await repository.getPendingBookingsCount();
      completedBookings = await repository.getCompletedBookingsCount();
      incompleteWorkerProfiles = await repository
          .getIncompleteWorkerProfilesCount();

      recentBookings = await repository.getRecentBookings(limit: 5);
      recentWorkers = await repository.getRecentWorkers(limit: 5);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD ADMIN DASHBOARD ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> users = [];

  Future<void> loadUsers() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      users = await repository.getAllUsers();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD USERS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> workers = [];

  Future<void> loadWorkers() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      workers = await repository.getAllWorkers();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD WORKERS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
