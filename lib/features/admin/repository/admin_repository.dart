import '../../../core/services/supabase_service.dart';

class AdminRepository {
  final SupabaseService _service;

  AdminRepository(this._service);

  Future<int> getTotalUsersCount() async {
    final response = await _service.client
        .from('profiles')
        .select('id')
        .eq('role', 'user');

    return (response as List).length;
  }

  Future<int> getTotalWorkersCount() async {
    final response = await _service.client
        .from('profiles')
        .select('id')
        .eq('role', 'worker');

    return (response as List).length;
  }

  Future<int> getTotalBookingsCount() async {
    final response = await _service.client.from('bookings').select('id');

    return (response as List).length;
  }

  Future<int> getPendingBookingsCount() async {
    final response = await _service.client
        .from('bookings')
        .select('id')
        .eq('status', 'pending');

    return (response as List).length;
  }

  Future<int> getCompletedBookingsCount() async {
    final response = await _service.client
        .from('bookings')
        .select('id')
        .eq('status', 'completed');

    return (response as List).length;
  }

  Future<int> getIncompleteWorkerProfilesCount() async {
    final response = await _service.client
        .from('worker_profiles')
        .select('id')
        .eq('is_profile_complete', false);

    return (response as List).length;
  }

  Future<List<Map<String, dynamic>>> getRecentBookings({int limit = 5}) async {
    final response = await _service.client
        .from('bookings')
        .select('''
          id,
          user_name,
          worker_name,
          worker_category,
          booking_date,
          booking_time,
          service_title,
          status,
          payment_amount,
          payment_status,
          urgency,
          created_at
        ''')
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getRecentWorkers({int limit = 5}) async {
    final response = await _service.client
        .from('worker_profiles')
        .select('''
          id,
          full_name,
          phone,
          category,
          location,
          experience_years,
          availability,
          is_profile_complete
        ''')
        .order('id', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _service.client
        .from('profiles')
        .select('id, full_name, phone, role, avatar_url')
        .eq('role', 'user')
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllWorkers() async {
    final response = await _service.client
        .from('worker_profiles')
        .select('''
        id,
        full_name,
        phone,
        category,
        location,
        experience_years,
        skills,
        rate,
        availability,
        is_profile_complete
      ''')
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<double> getTotalRevenue() async {
    final response = await _service.client
        .from('subscription_payments')
        .select('amount')
        .eq('payment_status', 'paid');

    final data = List<Map<String, dynamic>>.from(response);

    double total = 0;

    for (final item in data) {
      total += (item['amount'] as num?)?.toDouble() ?? 0;
    }

    return total;
  }

  Future<int> getActiveSubscriptionsCount() async {
    final response = await _service.client
        .from('worker_subscriptions')
        .select('id')
        .eq('status', 'active');

    return (response as List).length;
  }

  Future<int> getTrialSubscriptionsCount() async {
    final response = await _service.client
        .from('worker_subscriptions')
        .select('id')
        .eq('status', 'trial');

    return (response as List).length;
  }

  Future<int> getExpiredSubscriptionsCount() async {
    final response = await _service.client
        .from('worker_subscriptions')
        .select('id')
        .eq('status', 'expired');

    return (response as List).length;
  }
}
