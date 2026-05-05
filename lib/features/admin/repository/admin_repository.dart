import '../../../core/services/supabase_service.dart';

class AdminRepository {
  final SupabaseService _service;

  AdminRepository(this._service);

  Future<int> _count(String table, {String? column, dynamic value}) async {
    var query = _service.client.from(table).select('id');

    if (column != null) {
      query = query.eq(column, value);
    }

    final response = await query;
    return response.length;
  }

  Future<int> getTotalUsersCount() {
    return _count('profiles', column: 'role', value: 'user');
  }

  Future<int> getTotalWorkersCount() {
    return _count('profiles', column: 'role', value: 'worker');
  }

  Future<int> getTotalBookingsCount() {
    return _count('bookings');
  }

  Future<int> getPendingBookingsCount() {
    return _count('bookings', column: 'status', value: 'pending');
  }

  Future<int> getCompletedBookingsCount() {
    return _count('bookings', column: 'status', value: 'completed');
  }

  Future<int> getIncompleteWorkerProfilesCount() {
    return _count(
      'worker_profiles',
      column: 'is_profile_complete',
      value: false,
    );
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

    return data.fold<double>(0, (total, item) {
      return total + ((item['amount'] as num?)?.toDouble() ?? 0);
    });
  }

  Future<int> getActiveSubscriptionsCount() {
    return _count('worker_subscriptions', column: 'status', value: 'active');
  }

  Future<int> getTrialSubscriptionsCount() {
    return _count('worker_subscriptions', column: 'status', value: 'trial');
  }

  Future<int> getExpiredSubscriptionsCount() {
    return _count('worker_subscriptions', column: 'status', value: 'expired');
  }
}
