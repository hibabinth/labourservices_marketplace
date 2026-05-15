import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class ServiceRepository {
  final SupabaseService supabaseService;

  ServiceRepository(this.supabaseService);

  SupabaseClient get _client => supabaseService.client;

  Future<List<Map<String, dynamic>>> getTopWorkers() async {
    final workers = await _getCompleteWorkers(limit: 20);

    workers.sort((a, b) {
      final bRating = ((b['average_rating'] as num?) ?? 0).toDouble();
      final aRating = ((a['average_rating'] as num?) ?? 0).toDouble();
      return bRating.compareTo(aRating);
    });

    return workers.take(10).toList();
  }

  Future<List<Map<String, dynamic>>> getTopRatedWorkers() async {
    final workers = await _getCompleteWorkers(limit: 30);

    workers.sort((a, b) {
      final bRating = ((b['average_rating'] as num?) ?? 0).toDouble();
      final aRating = ((a['average_rating'] as num?) ?? 0).toDouble();

      if (bRating == aRating) {
        final bReviews = ((b['total_reviews'] as num?) ?? 0).toInt();
        final aReviews = ((a['total_reviews'] as num?) ?? 0).toInt();
        return bReviews.compareTo(aReviews);
      }

      return bRating.compareTo(aRating);
    });

    return workers.take(10).toList();
  }

  Future<List<Map<String, dynamic>>> getPopularWorkers() async {
    final workers = await _getCompleteWorkers(limit: 30);

    workers.sort((a, b) {
      final bReviews = ((b['total_reviews'] as num?) ?? 0).toInt();
      final aReviews = ((a['total_reviews'] as num?) ?? 0).toInt();

      if (bReviews == aReviews) {
        final bRating = ((b['average_rating'] as num?) ?? 0).toDouble();
        final aRating = ((a['average_rating'] as num?) ?? 0).toDouble();
        return bRating.compareTo(aRating);
      }

      return bReviews.compareTo(aReviews);
    });

    return workers.take(10).toList();
  }

  Future<List<Map<String, dynamic>>> searchWorkers({
    String? searchText,
    String? category,
  }) async {
    List<Map<String, dynamic>> workers = await _getCompleteWorkers();

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

    final worker = Map<String, dynamic>.from(workerProfile);
    await _attachWorkerExtraData(worker);

    return worker;
  }

  Future<List<Map<String, dynamic>>> getWorkerReviews(String workerId) async {
    final response = await _client
        .from('worker_reviews')
        .select('''
          id,
          booking_id,
          worker_id,
          user_id,
          rating,
          feedback,
          created_at,
          profiles (
            full_name,
            avatar_url
          )
        ''')
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);

    final reviews = List<Map<String, dynamic>>.from(response);

    for (final review in reviews) {
      final profile = review['profiles'] as Map<String, dynamic>?;
      String? avatarUrl = profile?['avatar_url'] as String?;

      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          !avatarUrl.startsWith('http')) {
        avatarUrl = _client.storage
            .from('user-profile-images')
            .getPublicUrl(avatarUrl);
      }

      review['user_avatar_url'] = avatarUrl;
      review['user_name'] = profile?['full_name'];
    }

    return reviews;
  }

  Future<Map<String, dynamic>> getWorkerRatingSummary(String workerId) async {
    final response = await _client
        .from('worker_reviews')
        .select('rating')
        .eq('worker_id', workerId);

    final reviews = List<Map<String, dynamic>>.from(response);

    if (reviews.isEmpty) {
      return {'average_rating': 0.0, 'total_reviews': 0};
    }

    double total = 0;

    for (final review in reviews) {
      total += ((review['rating'] as num?)?.toDouble() ?? 0);
    }

    return {
      'average_rating': total / reviews.length,
      'total_reviews': reviews.length,
    };
  }

  Future<List<Map<String, dynamic>>> _getCompleteWorkers({int? limit}) async {
    final baseQuery = _client
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

    final response = limit == null
        ? await baseQuery
        : await baseQuery.limit(limit);

    final workers = List<Map<String, dynamic>>.from(response);

    for (final worker in workers) {
      await _attachWorkerExtraData(worker);
    }

    return workers;
  }

  Future<void> _attachWorkerExtraData(Map<String, dynamic> worker) async {
    final workerId = worker['id']?.toString();

    if (workerId == null || workerId.isEmpty) {
      worker['avatar_url'] = null;
      worker['average_rating'] = 0.0;
      worker['total_reviews'] = 0;
      return;
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

    final ratingSummary = await getWorkerRatingSummary(workerId);

    worker['avatar_url'] = avatarUrl;
    worker['average_rating'] = ratingSummary['average_rating'];
    worker['total_reviews'] = ratingSummary['total_reviews'];
  }
}
