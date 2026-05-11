import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class WorkerProfileRepository {
  final SupabaseService _service;
  WorkerProfileRepository(this._service);

  Future<bool> isWorkerProfileComplete() async {
    final user = _service.currentUser;
    if (user == null) return false;

    final data = await _service.client
        .from('worker_profiles')
        .select('is_profile_complete')
        .eq('id', user.id)
        .maybeSingle();

    return (data?['is_profile_complete'] as bool?) ?? false;
  }

  Future<String?> getWorkerCategory() async {
    final user = _service.currentUser;
    if (user == null) return null;

    final data = await _service.client
        .from('worker_profiles')
        .select('category')
        .eq('id', user.id)
        .maybeSingle();

    return data?['category'] as String?;
  }

  Future<void> saveWorkerCategory(String category) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client.from('profiles').upsert({
      'id': user.id,
      'role': 'worker',
    });

    await _service.client.from('worker_profiles').upsert({
      'id': user.id,
      'category': category,
      'is_profile_complete': false,
    });
  }

  Future<void> saveWorkerProfile({
    required String fullName,
    required String phone,
    required String bio,
    required String location,
    required int experienceYears,
    required String skills,
    required String rate,
    required String availability,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone': phone,
      'role': 'worker',
    });

    final existing = await _service.client
        .from('worker_profiles')
        .select('category')
        .eq('id', user.id)
        .maybeSingle();

    await _service.client.from('worker_profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone': phone,
      'category': existing?['category'],
      'bio': bio,
      'location': location,
      'experience_years': experienceYears,
      'skills': skills,
      'rate': rate,
      'availability': availability,
      'is_profile_complete': true,
    });

    final existingSubscription = await _service.client
        .from('worker_subscriptions')
        .select('id')
        .eq('worker_id', user.id)
        .maybeSingle();

    if (existingSubscription == null) {
      await _service.client.from('worker_subscriptions').insert({
        'worker_id': user.id,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String(),
        'status': 'trial',
      });
    }
  }

  Future<String?> getProfileImageUrl() async {
    final user = _service.currentUser;
    if (user == null) return null;

    final data = await _service.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final storedValue = data?['avatar_url'] as String?;
    if (storedValue == null || storedValue.isEmpty) return null;

    if (storedValue.startsWith('http')) {
      return storedValue;
    }

    return _service.client.storage
        .from('worker-profile-images')
        .getPublicUrl(storedValue);
  }

  Future<String> uploadProfileImage(File file) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    final fileExt = path.extension(file.path);
    final fileName =
        '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
    final filePath = 'avatars/$fileName';

    await _service.client.storage
        .from('worker-profile-images')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    await _service.client
        .from('profiles')
        .update({'avatar_url': filePath})
        .eq('id', user.id);

    return _service.client.storage
        .from('worker-profile-images')
        .getPublicUrl(filePath);
  }

  Future<Map<String, dynamic>?> getWorkerProfile() async {
    final user = _service.currentUser;
    if (user == null) return null;

    final profile = await _service.client
        .from('profiles')
        .select('full_name, phone, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final workerProfile = await _service.client
        .from('worker_profiles')
        .select(
          'category, bio, location, experience_years, skills, rate, availability, is_profile_complete',
        )
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null && workerProfile == null) {
      return null;
    }

    return {
      'full_name': profile?['full_name'],
      'phone': profile?['phone'],
      'avatar_url': profile?['avatar_url'],
      'category': workerProfile?['category'],
      'bio': workerProfile?['bio'],
      'location': workerProfile?['location'],
      'experience_years': workerProfile?['experience_years'],
      'skills': workerProfile?['skills'],
      'rate': workerProfile?['rate'],
      'availability': workerProfile?['availability'],
      'is_profile_complete': workerProfile?['is_profile_complete'],
    };
  }

  Future<String> getWorkerStatus() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    final data = await _service.client
        .from('worker_profiles')
        .select('availability')
        .eq('id', user.id)
        .maybeSingle();

    return (data?['availability'] as String?) ?? 'Offline';
  }

  Future<Map<String, dynamic>?> getCurrentSubscription() async {
    final user = _service.currentUser;
    if (user == null) return null;

    final response = await _service.client
        .from('worker_subscriptions')
        .select('''
        id,
        status,
        start_date,
        end_date,
        subscription_plans (
          name,
          price,
          duration_days
        )
      ''')
        .eq('worker_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }

  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    final response = await _service.client
        .from('subscription_plans')
        .select('id, name, description, price, duration_days, is_active')
        .eq('is_active', true)
        .order('price', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> activateSubscription({
    required String planId,
    required num amount,
    required int durationDays,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    final now = DateTime.now();

    // 1. Save manual payment record for testing
    await _service.client.from('subscription_payments').insert({
      'worker_id': user.id,
      'plan_id': planId,
      'amount': amount,
      'payment_status': 'paid',
      'payment_id': 'manual_test_payment',
    });

    // 2. Remove old trial/old subscription
    await _service.client
        .from('worker_subscriptions')
        .delete()
        .eq('worker_id', user.id);

    // 3. Add new active subscription
    await _service.client.from('worker_subscriptions').insert({
      'worker_id': user.id,
      'plan_id': planId,
      'start_date': now.toIso8601String(),
      'end_date': now.add(Duration(days: durationDays)).toIso8601String(),
      'status': 'active',
    });
  }
}
