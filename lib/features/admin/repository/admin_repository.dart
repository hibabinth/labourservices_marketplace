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

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final response = await _service.client
        .from('bookings')
        .select('''
          id,
          user_id,
          worker_id,
          user_name,
          user_phone,
          worker_name,
          worker_phone,
          worker_category,
          booking_date,
          booking_time,
          booking_address,
          service_title,
          service_description,
          booking_note,
          urgency,
          status,
          payment_method,
          payment_amount,
          payment_status,
          razorpay_payment_id,
          created_at,
          accepted_at,
          started_at,
          completed_at,
          declined_at,
          rating,
          feedback
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getBookingsByStatus(String status) async {
    final response = await _service.client
        .from('bookings')
        .select('''
          id,
          user_id,
          worker_id,
          user_name,
          user_phone,
          worker_name,
          worker_phone,
          worker_category,
          booking_date,
          booking_time,
          booking_address,
          service_title,
          service_description,
          booking_note,
          urgency,
          status,
          payment_method,
          payment_amount,
          payment_status,
          razorpay_payment_id,
          created_at,
          accepted_at,
          started_at,
          completed_at,
          declined_at,
          rating,
          feedback
        ''')
        .eq('status', status)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
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

  Future<List<Map<String, dynamic>>> getSubscriptionsByStatus(
    String status,
  ) async {
    final response = await _service.client
        .from('worker_subscriptions')
        .select('''
          id,
          worker_id,
          plan_id,
          start_date,
          end_date,
          status,
          trial_booking_limit,
          used_trial_bookings,
          created_at,
          worker_profiles (
            full_name,
            phone,
            category,
            location
          ),
          subscription_plans (
            name,
            price,
            duration_days
          )
        ''')
        .eq('status', status)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSubscriptionPayments() async {
    final response = await _service.client
        .from('subscription_payments')
        .select('''
          id,
          worker_id,
          plan_id,
          amount,
          payment_status,
          payment_id,
          created_at,
          worker_profiles (
            full_name,
            phone,
            category
          ),
          subscription_plans (
            name,
            duration_days
          )
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<double> getTotalRevenue() async {
    final response = await _service.client
        .from('subscription_payments')
        .select('amount, payment_status')
        .eq('payment_status', 'paid');

    double total = 0;

    for (final item in response) {
      total += ((item['amount'] as num?)?.toDouble() ?? 0);
    }

    return total;
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

  Future<void> deleteUser(String userId) async {
    await _service.client.from('profiles').delete().eq('id', userId);
  }

  Future<void> deleteWorker(String workerId) async {
    await _service.client
        .from('subscription_payments')
        .delete()
        .eq('worker_id', workerId);

    await _service.client
        .from('worker_subscriptions')
        .delete()
        .eq('worker_id', workerId);

    await _service.client
        .from('worker_reviews')
        .delete()
        .eq('worker_id', workerId);

    await _service.client.from('worker_profiles').delete().eq('id', workerId);

    await _service.client.from('profiles').delete().eq('id', workerId);
  }
}
