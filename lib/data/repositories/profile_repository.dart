import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

class ProfileRepository {
  final SupabaseService _service;
  ProfileRepository(this._service);

  Future<void> saveRole(String role) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client.from('profiles').upsert({
      'id': user.id,
      'role': role,
    });
  }

  Future<String?> getRole() async {
    final user = _service.currentUser;
    if (user == null) {
      debugPrint('GET ROLE => currentUser is null');
      return null;
    }

    debugPrint('GET ROLE USER ID => ${user.id}');
    debugPrint('GET ROLE USER EMAIL => ${user.email}');

    final data = await _service.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    debugPrint('GET ROLE DB RESPONSE => $data');

    return data?['role'] as String?;
  }

  Future<void> saveUserProfile({
    required String fullName,
    required String phone,
    required String location,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone': phone,
      'location': location,
      'is_profile_complete': true,
    });
  }

  Future<bool> isUserProfileComplete() async {
    final user = _service.currentUser;
    if (user == null) return false;

    final data = await _service.client
        .from('profiles')
        .select('is_profile_complete, role')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return false;
    if (data['role'] != 'user') return false;

    return (data['is_profile_complete'] as bool?) ?? false;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _service.currentUser;
    if (user == null) return null;

    return await _service.client
        .from('profiles')
        .select(
          'full_name, phone, location, avatar_url, role, is_profile_complete',
        )
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<String?> getUserProfileImageUrl() async {
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
        .from('user-profile-images')
        .getPublicUrl(storedValue);
  }

  Future<String> uploadUserProfileImage(File file) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    final fileExt = path.extension(file.path);
    final fileName =
        '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
    final filePath = 'avatars/$fileName';

    try {
      print('Uploading to bucket: user-profile-images');
      print('Uploading filePath: $filePath');
      print('Local file exists: ${file.existsSync()}');
      print('Current user id: ${user.id}');

      await _service.client.storage
          .from('user-profile-images')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      print('Upload success');

      await _service.client
          .from('profiles')
          .update({'avatar_url': filePath})
          .eq('id', user.id);

      print('Profile avatar_url updated in DB: $filePath');

      final publicUrl = _service.client.storage
          .from('user-profile-images')
          .getPublicUrl(filePath);

      print('Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('UPLOAD USER PROFILE IMAGE ERROR => $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    required String location,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client
        .from('profiles')
        .update({'full_name': fullName, 'phone': phone, 'location': location})
        .eq('id', user.id);
  }
}
