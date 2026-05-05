import 'package:flutter/material.dart';
import '../../chat/repository/chat_repository.dart';
import '../repository/worker_booking_repository.dart';
import '../repository/worker_profile_repository.dart';

class WorkerHomeViewModel extends ChangeNotifier {
  final WorkerBookingRepository bookingRepository;
  final WorkerProfileRepository profileRepository;
  final ChatRepository chatRepository;

  WorkerHomeViewModel({
    required this.bookingRepository,
    required this.profileRepository,
    required this.chatRepository,
  });

  bool isLoading = false;
  String? errorMessage;

  int pendingBookings = 0;
  int unreadChats = 0;
  int completedToday = 0;
  int todayJobs = 0;
  String workerStatus = 'Offline';

  List<Map<String, dynamic>> recentPendingBookings = [];

  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      pendingBookings = await bookingRepository.getPendingBookingCount();
      todayJobs = await bookingRepository.getTodayJobsCount();
      completedToday = await bookingRepository.getCompletedWorksTodayCount();
      recentPendingBookings = await bookingRepository.getRecentPendingBookings(
        limit: 3,
      );
      workerStatus = await profileRepository.getWorkerStatus();

      // Change this method name to match your ChatRepository
      unreadChats = await chatRepository.getUnreadChatCount();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD WORKER DASHBOARD ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
