import '../../../core/services/supabase_service.dart';

class ChatRepository {
  final SupabaseService _service;

  ChatRepository(this._service);

  String? get currentUserId => _service.currentUser?.id;

  Future<Map<String, dynamic>?> getChatByParticipants({
    required String userId,
    required String workerId,
  }) async {
    final response = await _service.client
        .from('booking_chats')
        .select()
        .eq('user_id', userId)
        .eq('worker_id', workerId)
        .order('created_at', ascending: true)
        .limit(1);

    final chats = List<Map<String, dynamic>>.from(response);
    if (chats.isEmpty) return null;
    return chats.first;
  }

  Future<String> getOrCreateChat({
    required String userId,
    required String workerId,
  }) async {
    final existing = await getChatByParticipants(
      userId: userId,
      workerId: workerId,
    );

    if (existing != null) {
      return existing['id'].toString();
    }

    final inserted = await _service.client
        .from('booking_chats')
        .upsert({
          'user_id': userId,
          'worker_id': workerId,
        }, onConflict: 'user_id,worker_id')
        .select('id')
        .single();

    return inserted['id'].toString();
  }

  Future<int> _getUnreadCountForChat({
    required String chatId,
    required String currentUserId,
  }) async {
    final response = await _service.client
        .from('chat_messages')
        .select('id')
        .eq('chat_id', chatId)
        .neq('sender_id', currentUserId)
        .isFilter('seen_at', null);

    return List<Map<String, dynamic>>.from(response).length;
  }

  Future<String> _getLastMessagePreview(String chatId) async {
    final response = await _service.client
        .from('chat_messages')
        .select('message')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return (response?['message'] ?? '').toString();
  }

  Future<int> getUnreadChatCount() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final response = await _service.client
        .from('chat_messages')
        .select('id, booking_chats!inner(worker_id)')
        .eq('booking_chats.worker_id', user.id)
        .neq('sender_id', user.id)
        .isFilter('seen_at', null);

    return List<Map<String, dynamic>>.from(response).length;
  }

  Future<List<Map<String, dynamic>>> getUserChats() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _service.client
        .from('booking_chats')
        .select('''
          id,
          user_id,
          worker_id,
          created_at,
          worker_profiles!booking_chats_worker_id_fkey(
            full_name,
            phone,
            category
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final chats = List<Map<String, dynamic>>.from(response);

    for (final chat in chats) {
      final chatId = chat['id'].toString();
      chat['unread_count'] = await _getUnreadCountForChat(
        chatId: chatId,
        currentUserId: user.id,
      );
      chat['last_message'] = await _getLastMessagePreview(chatId);
    }

    return chats;
  }

  Future<List<Map<String, dynamic>>> getWorkerChats() async {
    final user = _service.currentUser;
    if (user == null) throw Exception('Worker not logged in');

    final response = await _service.client
        .from('booking_chats')
        .select('''
          id,
          user_id,
          worker_id,
          created_at,
          profiles!booking_chats_user_id_fkey(
            full_name,
            phone
          )
        ''')
        .eq('worker_id', user.id)
        .order('created_at', ascending: false);

    final chats = List<Map<String, dynamic>>.from(response);

    for (final chat in chats) {
      final chatId = chat['id'].toString();
      chat['unread_count'] = await _getUnreadCountForChat(
        chatId: chatId,
        currentUserId: user.id,
      );
      chat['last_message'] = await _getLastMessagePreview(chatId);
    }

    return chats;
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final response = await _service.client
        .from('chat_messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return _service.client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .map((rows) {
          final messages = List<Map<String, dynamic>>.from(rows);
          messages.sort((a, b) {
            final aTime = (a['created_at'] ?? '').toString();
            final bTime = (b['created_at'] ?? '').toString();
            return aTime.compareTo(bTime);
          });
          return messages;
        });
  }

  Future<void> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client.from('chat_messages').insert({
      'chat_id': chatId,
      'sender_id': user.id,
      'message': message,
      'is_edited': false,
    });
  }

  Future<void> updateMessage({
    required String messageId,
    required String newMessage,
  }) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client
        .from('chat_messages')
        .update({'message': newMessage, 'is_edited': true})
        .eq('id', messageId)
        .eq('sender_id', user.id);
  }

  Future<void> deleteMessage(String messageId) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client
        .from('chat_messages')
        .delete()
        .eq('id', messageId)
        .eq('sender_id', user.id);
  }

  Future<void> markMessagesAsSeen(String chatId) async {
    final user = _service.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _service.client
        .from('chat_messages')
        .update({'seen_at': DateTime.now().toIso8601String()})
        .eq('chat_id', chatId)
        .neq('sender_id', user.id)
        .isFilter('seen_at', null);
  }
}
