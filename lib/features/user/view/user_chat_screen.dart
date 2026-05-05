import 'package:flutter/material.dart';
import 'package:labour_service/features/chat/view/chat_room_screen.dart';
import 'package:labour_service/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:provider/provider.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  Future<void> _loadChats() async {
    await context.read<ChatViewModel>().loadUserChats();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text('Chats', style: TextStyle(color: Color(0xFF1C274C))),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
        actions: [
          IconButton(
            onPressed: _loadChats,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadChats,
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.userChats.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Text(
                        'No chats yet.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7A8599),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.userChats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = vm.userChats[index];
                    final workerProfile = Map<String, dynamic>.from(
                      chat['worker_profiles'] ?? {},
                    );

                    final chatId = (chat['id'] ?? '').toString();
                    final workerName = (workerProfile['full_name'] ?? 'Worker')
                        .toString();
                    final workerCategory = (workerProfile['category'] ?? '')
                        .toString();
                    final workerPhone = (workerProfile['phone'] ?? '')
                        .toString();
                    final unreadCount = (chat['unread_count'] ?? 0) as int;
                    final lastMessage = (chat['last_message'] ?? '').toString();

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        if (chatId.isEmpty) return;

                        await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              chatId: chatId,
                              title: workerName,
                              subtitle: workerCategory.isEmpty
                                  ? workerPhone
                                  : workerPhone.isEmpty
                                  ? workerCategory
                                  : '$workerCategory • $workerPhone',
                            ),
                          ),
                        );

                        if (!mounted) return;
                        await _loadChats();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFEAF1FF),
                              child: Text(
                                workerName.isNotEmpty
                                    ? workerName[0].toUpperCase()
                                    : 'W',
                                style: const TextStyle(
                                  color: Color(0xFF1E63F3),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workerName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1C274C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lastMessage.isNotEmpty
                                        ? lastMessage
                                        : workerCategory.isNotEmpty
                                        ? workerCategory
                                        : (workerPhone.isNotEmpty
                                              ? workerPhone
                                              : 'Start chatting'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: unreadCount > 0
                                          ? const Color(0xFF1C274C)
                                          : const Color(0xFF7A8599),
                                      fontWeight: unreadCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Color(0xFF7A8599),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E63F3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      unreadCount > 99
                                          ? '99+'
                                          : unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
