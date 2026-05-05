import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class ServiceRepository {
  final SupabaseService supabaseService;

  ServiceRepository(this.supabaseService);

  SupabaseClient get _client => supabaseService.client;

  Future<List<Map<String, dynamic>>> getTopWorkers() async {
    final response = await _client
        .from('worker_profiles')
        .select('''
          id,
          category,
          bio,
          location,
          experience_years,
          full_name,
          phone,
          skills,
          rate,
          availability,
          is_profile_complete
        ''')
        .eq('is_profile_complete', true)
        .limit(10);

    final workers = List<Map<String, dynamic>>.from(response);

    for (final worker in workers) {
      final workerId = worker['id']?.toString();
      if (workerId == null || workerId.isEmpty) {
        worker['avatar_url'] = null;
        continue;
      }

      final profile = await _client
          .from('profiles')
          .select('avatar_url')
          .eq('id', workerId)
          .maybeSingle();

      String? avatarUrl = profile?['avatar_url'] as String?;
      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          !avatarUrl.startsWith('http')) {
        avatarUrl = _client.storage
            .from('worker-profile-images')
            .getPublicUrl(avatarUrl);
      }

      worker['avatar_url'] = avatarUrl;
    }

    return workers;
  }

  Future<List<Map<String, dynamic>>> searchWorkers({
    String? searchText,
    String? category,
  }) async {
    final response = await _client
        .from('worker_profiles')
        .select('''
          id,
          category,
          bio,
          location,
          experience_years,
          full_name,
          phone,
          skills,
          rate,
          availability,
          is_profile_complete
        ''')
        .eq('is_profile_complete', true);

    List<Map<String, dynamic>> workers = List<Map<String, dynamic>>.from(
      response,
    );

    if (category != null && category.isNotEmpty) {
      workers = workers.where((worker) {
        final workerCategory = (worker['category'] ?? '')
            .toString()
            .toLowerCase();
        return workerCategory == category.toLowerCase();
      }).toList();
    }

    if (searchText != null && searchText.trim().isNotEmpty) {
      final query = searchText.trim().toLowerCase();

      workers = workers.where((worker) {
        final fullName = (worker['full_name'] ?? '').toString().toLowerCase();
        final workerCategory = (worker['category'] ?? '')
            .toString()
            .toLowerCase();
        final location = (worker['location'] ?? '').toString().toLowerCase();
        final skills = (worker['skills'] ?? '').toString().toLowerCase();
        final phone = (worker['phone'] ?? '').toString().toLowerCase();

        return fullName.contains(query) ||
            workerCategory.contains(query) ||
            location.contains(query) ||
            skills.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    for (final worker in workers) {
      final workerId = worker['id']?.toString();
      if (workerId == null || workerId.isEmpty) {
        worker['avatar_url'] = null;
        continue;
      }

      final profile = await _client
          .from('profiles')
          .select('avatar_url')
          .eq('id', workerId)
          .maybeSingle();

      String? avatarUrl = profile?['avatar_url'] as String?;
      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          !avatarUrl.startsWith('http')) {
        avatarUrl = _client.storage
            .from('worker-profile-images')
            .getPublicUrl(avatarUrl);
      }

      worker['avatar_url'] = avatarUrl;
    }

    return workers;
  }

  Future<Map<String, dynamic>?> getWorkerById(String workerId) async {
    final workerProfile = await _client
        .from('worker_profiles')
        .select('''
          id,
          category,
          bio,
          location,
          experience_years,
          full_name,
          phone,
          skills,
          rate,
          availability,
          is_profile_complete
        ''')
        .eq('id', workerId)
        .maybeSingle();

    if (workerProfile == null) return null;

    final profile = await _client
        .from('profiles')
        .select('avatar_url')
        .eq('id', workerId)
        .maybeSingle();

    String? avatarUrl = profile?['avatar_url'] as String?;
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        !avatarUrl.startsWith('http')) {
      avatarUrl = _client.storage
          .from('worker-profile-images')
          .getPublicUrl(avatarUrl);
    }

    return {...workerProfile, 'avatar_url': avatarUrl};
  }
}
