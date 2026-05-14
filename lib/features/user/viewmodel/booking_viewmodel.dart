import 'package:flutter/material.dart';
import '../repository/booking_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingRepository repository;

  BookingViewModel({required this.repository});

  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> bookings = [];

  Future<bool> createBooking({
    required String workerId,
    required String workerName,
    required String workerPhone,
    required String workerCategory,
    required String userName,
    required String userPhone,
    required String bookingDate,
    required String bookingTime,
    required String bookingAddress,
    required String serviceTitle,
    required String serviceDescription,
    required String bookingNote,
    required String urgency,
    required String paymentMethod,
    required double paymentAmount,
    required String paymentId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await repository.createBooking(
        workerId: workerId,
        workerName: workerName,
        workerPhone: workerPhone,
        workerCategory: workerCategory,
        userName: userName,
        userPhone: userPhone,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        bookingAddress: bookingAddress,
        serviceTitle: serviceTitle,
        serviceDescription: serviceDescription,
        bookingNote: bookingNote,
        urgency: urgency,
        paymentMethod: paymentMethod,
        paymentAmount: paymentAmount,
        paymentId: paymentId,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('CREATE BOOKING ERROR => $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyBookings() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      bookings = await repository.getMyBookings();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('LOAD BOOKINGS ERROR => $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback({
    required String bookingId,
    required double rating,
    required String feedback,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await repository.submitFeedback(
        bookingId: bookingId,
        rating: rating,
        feedback: feedback,
      );

      await loadMyBookings();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('SUBMIT FEEDBACK ERROR => $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
