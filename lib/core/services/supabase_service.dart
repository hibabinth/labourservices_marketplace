import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;
  SupabaseService(this.client);

  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;
}
