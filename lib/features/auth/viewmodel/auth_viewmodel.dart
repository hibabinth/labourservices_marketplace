import 'dart:io';

import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../worker/repository/worker_profile_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final WorkerProfileRepository workerProfileRepository;

  AuthViewModel({
    required this.authRepository,
    required this.profileRepository,
    required this.workerProfileRepository,
  });

  bool isLoading = false;
  String? errorMessage;

  Map<String, dynamic>? userProfileData;
  String? userProfileImageUrl;

  Map<String, dynamic>? workerProfileData;
  String? profileImageUrl;

  Map<String, dynamic>? workerSubscriptionData;
  List<Map<String, dynamic>> subscriptionPlans = [];

  bool get isLoggedIn => authRepository.currentUser != null;

  bool get hasActiveSubscription {
    final subscription = workerSubscriptionData;
    if (subscription == null) return false;

    final status = subscription['status']?.toString().toLowerCase();
    final endDate = DateTime.tryParse(
      subscription['end_date']?.toString() ?? '',
    );

    if (status != 'active') return false;
    if (endDate == null) return false;

    return DateTime.now().isBefore(endDate);
  }

  bool get canUseWorkerFeatures {
    final subscription = workerSubscriptionData;
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

  bool get isSubscriptionExpired {
    final subscription = workerSubscriptionData;
    if (subscription == null) return true;

    final endDate = DateTime.tryParse(
      subscription['end_date']?.toString() ?? '',
    );

    if (endDate == null) return true;

    return !DateTime.now().isBefore(endDate);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    errorMessage = value;
    notifyListeners();
  }

  String _mapError(Object e) {
    final message = e.toString().toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email before signing in';
    }
    if (message.contains('user already registered')) {
      return 'This email is already registered';
    }
    if (message.contains('password should be at least')) {
      return 'Password must be at least 6 characters';
    }
    if (message.contains('invalid email') ||
        message.contains('email_address_invalid')) {
      return 'Please enter a valid email address';
    }
    if (message.contains('redirect url not allowed')) {
      return 'Redirect URL is not configured in Supabase';
    }
    if (message.contains('network')) {
      return 'Network error. Please try again';
    }
    if (message.contains('cancelled')) {
      return 'Google sign in cancelled';
    }
    if (message.contains('missing google id token')) {
      return 'Google sign in failed. Missing ID token.';
    }
    if (message.contains('missing google access token')) {
      return 'Google sign in failed. Missing access token.';
    }
    if (message.contains('no credential available') ||
        message.contains('no credentials available')) {
      return 'No Google credential available on this device.';
    }
    if (message.contains('developer console is not set up correctly')) {
      return 'Google Sign-In is not configured correctly in Firebase/Google Cloud/Supabase.';
    }
    if (message.contains('invalid role selection')) {
      return 'This role cannot be selected from the app.';
    }

    return e.toString();
  }

  bool isPrivilegedRole(String? role) {
    return role == 'admin' || role == 'super_admin';
  }

  Future<bool> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await authRepository.signUpWithEmail(
        fullName: fullName,
        email: email.trim().toLowerCase(),
        password: password,
      );

      return true;
    } catch (e) {
      debugPrint('SIGNUP ERROR => $e');
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await authRepository.signInWithEmail(
        email: email.trim().toLowerCase(),
        password: password,
      );

      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      await authRepository.signInWithGoogle();
      return true;
    } catch (e) {
      debugPrint('GOOGLE SIGN IN ERROR => $e');
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithPhone(String phone) async {
    try {
      _setLoading(true);
      _setError(null);

      await authRepository.signInWithPhone(phone: phone);
      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await authRepository.verifyPhoneOtp(phone: phone, token: otp);
      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await authRepository.resetPassword(email.trim().toLowerCase());
      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);
      await authRepository.signOut();

      userProfileData = null;
      userProfileImageUrl = null;
      workerProfileData = null;
      profileImageUrl = null;
      workerSubscriptionData = null;
      subscriptionPlans = [];
    } catch (e) {
      _setError(_mapError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveRole(String role) async {
    try {
      _setLoading(true);
      _setError(null);

      final cleanedRole = role.trim().toLowerCase();

      if (isPrivilegedRole(cleanedRole)) {
        throw Exception('Invalid role selection');
      }

      if (cleanedRole != 'user' && cleanedRole != 'worker') {
        throw Exception('Invalid role selection');
      }

      await profileRepository.saveRole(cleanedRole);
    } catch (e) {
      _setError(_mapError(e));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getRole() async {
    try {
      final role = await profileRepository.getRole();
      return role?.trim().toLowerCase();
    } catch (_) {
      return null;
    }
  }

  Future<bool> isWorkerProfileComplete() async {
    try {
      return await workerProfileRepository.isWorkerProfileComplete();
    } catch (e) {
      _setError(_mapError(e));
      return false;
    }
  }

  Future<String?> getWorkerCategory() async {
    try {
      final category = await workerProfileRepository.getWorkerCategory();
      return category?.trim();
    } catch (e) {
      _setError(_mapError(e));
      return null;
    }
  }

  Future<bool> saveWorkerCategory(String category) async {
    try {
      _setLoading(true);
      _setError(null);
      await workerProfileRepository.saveWorkerCategory(category.trim());
      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveWorkerProfile({
    required String fullName,
    required String phone,
    required String bio,
    required String location,
    required int experienceYears,
    required String skills,
    required String rate,
    required String availability,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await workerProfileRepository.saveWorkerProfile(
        fullName: fullName,
        phone: phone,
        bio: bio,
        location: location,
        experienceYears: experienceYears,
        skills: skills,
        rate: rate,
        availability: availability,
      );

      await loadWorkerSubscription();

      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> loadProfileImageUrl() async {
    try {
      final url = await workerProfileRepository.getProfileImageUrl();
      profileImageUrl = url;
      notifyListeners();
      return url;
    } catch (e) {
      _setError(_mapError(e));
      return null;
    }
  }

  Future<bool> uploadProfileImage(File file) async {
    try {
      _setLoading(true);
      _setError(null);

      final url = await workerProfileRepository.uploadProfileImage(file);
      profileImageUrl = url;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWorkerProfile() async {
    try {
      _setLoading(true);
      _setError(null);

      workerProfileData = await workerProfileRepository.getWorkerProfile();
      notifyListeners();
    } catch (e) {
      _setError(_mapError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWorkerSubscription() async {
    try {
      workerSubscriptionData = await workerProfileRepository
          .getCurrentSubscription();

      notifyListeners();
    } catch (e) {
      errorMessage = _mapError(e);
      debugPrint('LOAD WORKER SUBSCRIPTION ERROR => $e');
      notifyListeners();
    }
  }

  Future<void> loadSubscriptionPlans() async {
    try {
      _setLoading(true);
      _setError(null);

      subscriptionPlans = await workerProfileRepository.getSubscriptionPlans();
    } catch (e) {
      _setError(_mapError(e));
      debugPrint('LOAD SUBSCRIPTION PLANS ERROR => $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> activateWorkerSubscription({
    required String planId,
    required num amount,
    required int durationDays,
    required String paymentId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await workerProfileRepository.activateSubscription(
        planId: planId,
        amount: amount,
        durationDays: durationDays,
        paymentId: paymentId,
      );

      await loadWorkerSubscription();
      return true;
    } catch (e) {
      _setError(_mapError(e));
      debugPrint('ACTIVATE WORKER SUBSCRIPTION ERROR => $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveUserProfile({
    required String fullName,
    required String phone,
    required String location,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await profileRepository.saveUserProfile(
        fullName: fullName,
        phone: phone,
        location: location,
      );

      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isUserProfileComplete() async {
    try {
      return await profileRepository.isUserProfileComplete();
    } catch (e) {
      _setError(_mapError(e));
      return false;
    }
  }

  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _setError(null);

      userProfileData = await profileRepository.getUserProfile();
      notifyListeners();
    } catch (e) {
      _setError(_mapError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> loadUserProfileImageUrl() async {
    try {
      final url = await profileRepository.getUserProfileImageUrl();
      userProfileImageUrl = url;
      notifyListeners();
      return url;
    } catch (e) {
      _setError(_mapError(e));
      return null;
    }
  }

  Future<bool> uploadUserProfileImage(File file) async {
    try {
      _setLoading(true);
      _setError(null);

      final url = await profileRepository.uploadUserProfileImage(file);
      userProfileImageUrl = url;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile({
    required String fullName,
    required String phone,
    required String location,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await profileRepository.updateUserProfile(
        fullName: fullName,
        phone: phone,
        location: location,
      );

      return true;
    } catch (e) {
      _setError(_mapError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
