import 'package:flutter/material.dart';
import '../../chat/repository/chat_repository.dart';
import '../repository/worker_booking_repository.dart';

class WorkerBookingViewModel extends ChangeNotifier {
  final WorkerBookingRepository repository;
  final ChatRepository chatRepository;

  WorkerBookingViewModel({
    required this.repository,
    required this.chatRepository,
  });

  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> bookings = [];

  String selectedStatus = 'all';

  Future<void> loadWorkerBookings({String? status}) async {
    try {
      isLoading = true;
      errorMessage = null;

      if (status != null) {
        selectedStatus = status;
      }

      notifyListeners();

      bookings = await repository.getWorkerBookings(status: selectedStatus);
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('LOAD WORKER BOOKINGS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeTab(String status) async {
    await loadWorkerBookings(status: status);
  }

  Future<bool> updateStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await repository.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );

      await loadWorkerBookings(status: selectedStatus);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('UPDATE WORKER BOOKING STATUS ERROR => $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
