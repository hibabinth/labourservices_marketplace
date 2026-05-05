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

    // If old data already contains full URL, use it directly
    if (storedValue.startsWith('http')) {
      return storedValue;
    }

    // If DB stores storage path like avatars/xxx.jpg
    final imageUrl = _service.client.storage
        .from('worker-profile-images')
        .getPublicUrl(storedValue);

    return imageUrl;
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

    // Save ONLY the storage path in DB
    await _service.client
        .from('profiles')
        .update({'avatar_url': filePath})
        .eq('id', user.id);

    final imageUrl = _service.client.storage
        .from('worker-profile-images')
        .getPublicUrl(filePath);

    return imageUrl;
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
}
