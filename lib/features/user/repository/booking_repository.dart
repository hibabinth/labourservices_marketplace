import '../../../core/services/supabase_service.dart';

class BookingRepository {
  final SupabaseService _service;

  BookingRepository(this._service);

  Future<void> createBooking({
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
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client.from('bookings').insert({
      'user_id': user.id,
      'user_name': userName,
      'user_phone': userPhone,
      'worker_id': workerId,
      'worker_name': workerName,
      'worker_phone': workerPhone,
      'worker_category': workerCategory,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'booking_address': bookingAddress,
      'service_title': serviceTitle,
      'service_description': serviceDescription,
      'booking_note': bookingNote,
      'urgency': urgency,
      'status': 'pending',
      'payment_method': paymentMethod,
      'payment_amount': paymentAmount,
      'payment_status': 'paid',
      'razorpay_payment_id': paymentId,
    });
  }

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _service.client
        .from('bookings')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> submitFeedback({
    required String bookingId,
    required double rating,
    required String feedback,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    final booking = await _service.client
        .from('bookings')
        .select('id, worker_id, user_id, status')
        .eq('id', bookingId)
        .eq('user_id', user.id)
        .eq('status', 'completed')
        .maybeSingle();

    if (booking == null) {
      throw Exception('You can review only completed bookings');
    }

    final workerId = booking['worker_id']?.toString();
    if (workerId == null || workerId.isEmpty) {
      throw Exception('Worker not found for this booking');
    }

    await _service.client
        .from('bookings')
        .update({'rating': rating, 'feedback': feedback})
        .eq('id', bookingId)
        .eq('user_id', user.id)
        .eq('status', 'completed');

    await _service.client.from('worker_reviews').upsert({
      'booking_id': bookingId,
      'worker_id': workerId,
      'user_id': user.id,
      'rating': rating,
      'feedback': feedback,
    }, onConflict: 'booking_id');
  }
}
