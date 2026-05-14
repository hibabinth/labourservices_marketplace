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

  double totalRevenue = 0;
  int activeSubscriptions = 0;
  int trialSubscriptions = 0;
  int expiredSubscriptions = 0;

  List<Map<String, dynamic>> recentBookings = [];
  List<Map<String, dynamic>> recentWorkers = [];

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> workers = [];
  List<Map<String, dynamic>> adminBookings = [];

  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        repository.getTotalUsersCount(),
        repository.getTotalWorkersCount(),
        repository.getTotalBookingsCount(),
        repository.getPendingBookingsCount(),
        repository.getCompletedBookingsCount(),
        repository.getIncompleteWorkerProfilesCount(),
        repository.getTotalRevenue(),
        repository.getActiveSubscriptionsCount(),
        repository.getTrialSubscriptionsCount(),
        repository.getExpiredSubscriptionsCount(),
        repository.getRecentBookings(limit: 5),
        repository.getRecentWorkers(limit: 5),
      ]);

      totalUsers = results[0] as int;
      totalWorkers = results[1] as int;
      totalBookings = results[2] as int;
      pendingBookings = results[3] as int;
      completedBookings = results[4] as int;
      incompleteWorkerProfiles = results[5] as int;

      totalRevenue = results[6] as double;
      activeSubscriptions = results[7] as int;
      trialSubscriptions = results[8] as int;
      expiredSubscriptions = results[9] as int;

      recentBookings = results[10] as List<Map<String, dynamic>>;
      recentWorkers = results[11] as List<Map<String, dynamic>>;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD ADMIN DASHBOARD ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers({bool forceRefresh = false}) async {
    if (users.isNotEmpty && !forceRefresh) return;

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

  Future<void> loadWorkers({bool forceRefresh = false}) async {
    if (workers.isNotEmpty && !forceRefresh) return;

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

  Future<void> loadAdminBookings({required String status}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      if (status == 'all') {
        adminBookings = await repository.getAllBookings();
      } else {
        adminBookings = await repository.getBookingsByStatus(status);
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD ADMIN BOOKINGS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
