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

    final response = await _service.client
        .from('bookings')
        .select()
        .eq('id', bookingId)
        .eq('worker_id', user.id)
        .maybeSingle();

    return response;
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

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
