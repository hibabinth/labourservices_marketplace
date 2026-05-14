import '../../../core/services/supabase_service.dart';

class WorkerBookingRepository {
  final SupabaseService _service;

  WorkerBookingRepository(this._service);

  Future<List<Map<String, dynamic>>> getWorkerBookings({String? status}) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    dynamic query = _service.client
        .from('bookings')
        .select()
        .eq('worker_id', user.id);

    if (status != null && status != 'all') {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    return await _service.client
        .from('bookings')
        .select()
        .eq('id', bookingId)
        .eq('worker_id', user.id)
        .maybeSingle();
  }

  Future<bool> canAcceptBooking() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final subscription = await _service.client
        .from('worker_subscriptions')
        .select('status, used_trial_bookings, trial_booking_limit, end_date')
        .eq('worker_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (subscription == null) return false;

    final status = subscription['status']?.toString().toLowerCase();
    final endDate = DateTime.tryParse(
      subscription['end_date']?.toString() ?? '',
    );

    if (endDate == null) return false;
    if (!DateTime.now().isBefore(endDate)) return false;

    if (status == 'active') return true;

    if (status == 'trial') {
      final used =
          int.tryParse(
            subscription['used_trial_bookings']?.toString() ?? '0',
          ) ??
          0;

      final limit =
          int.tryParse(
            subscription['trial_booking_limit']?.toString() ?? '2',
          ) ??
          2;

      return used < limit;
    }

    return false;
  }

  Future<void> incrementTrialBookingUsage() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final subscription = await _service.client
        .from('worker_subscriptions')
        .select('id, status, used_trial_bookings, trial_booking_limit')
        .eq('worker_id', user.id)
        .eq('status', 'trial')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (subscription == null) return;

    final used =
        int.tryParse(subscription['used_trial_bookings']?.toString() ?? '0') ??
        0;

    final limit =
        int.tryParse(subscription['trial_booking_limit']?.toString() ?? '2') ??
        2;

    if (used >= limit) return;

    await _service.client
        .from('worker_subscriptions')
        .update({'used_trial_bookings': used + 1})
        .eq('id', subscription['id']);
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    if (status == 'accepted') {
      final canAccept = await canAcceptBooking();

      if (!canAccept) {
        throw Exception('Trial limit reached. Please subscribe to continue.');
      }
    }

    final updateData = <String, dynamic>{'status': status};

    if (status == 'accepted') {
      updateData['accepted_at'] = DateTime.now().toIso8601String();
    } else if (status == 'working') {
      updateData['started_at'] = DateTime.now().toIso8601String();
    } else if (status == 'declined') {
      updateData['declined_at'] = DateTime.now().toIso8601String();
    } else if (status == 'completed') {
      updateData['completed_at'] = DateTime.now().toIso8601String();
    }

    await _service.client
        .from('bookings')
        .update(updateData)
        .eq('id', bookingId)
        .eq('worker_id', user.id);

    if (status == 'accepted') {
      await incrementTrialBookingUsage();
    }
  }

  Future<int> getPendingBookingCount() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final response = await _service.client
        .from('bookings')
        .select('id')
        .eq('worker_id', user.id)
        .eq('status', 'pending');

    return (response as List).length;
  }

  Future<int> getTodayJobsCount() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final response = await _service.client
        .from('bookings')
        .select('id')
        .eq('worker_id', user.id)
        .inFilter('status', ['accepted', 'working', 'completed'])
        .gte('booking_date', start.toIso8601String())
        .lt('booking_date', end.toIso8601String());

    return (response as List).length;
  }

  Future<int> getCompletedWorksTodayCount() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final response = await _service.client
        .from('bookings')
        .select('id')
        .eq('worker_id', user.id)
        .eq('status', 'completed')
        .gte('completed_at', start.toIso8601String())
        .lt('completed_at', end.toIso8601String());

    return (response as List).length;
  }

  Future<List<Map<String, dynamic>>> getRecentPendingBookings({
    int limit = 3,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final response = await _service.client
        .from('bookings')
        .select()
        .eq('worker_id', user.id)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }
}
