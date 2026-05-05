import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseService _service;
  AuthRepository(this._service);

  SupabaseClient get _client => _service.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cleanedEmail = email.trim().toLowerCase();

    return await _client.auth.signUp(
      email: cleanedEmail,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<AuthResponse> signInWithGoogle() async {
    const webClientId =
        '1087898841741-uav9m68d7sb21270ha92tnhc8eg34uti.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(serverClientId: webClientId);

    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    final idToken = googleUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Missing Google ID token');
    }

    const scopes = <String>['email', 'profile', 'openid'];

    final authorization = await googleUser.authorizationClient.authorizeScopes(
      scopes,
    );

    final accessToken = authorization.accessToken;
    if (accessToken.isEmpty) {
      throw Exception('Missing Google access token');
    }

    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signInWithPhone({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
