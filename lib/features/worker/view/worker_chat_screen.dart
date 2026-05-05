import 'package:flutter/material.dart';
import 'package:labour_service/features/chat/view/chat_room_screen.dart';
import 'package:labour_service/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:provider/provider.dart';

class WorkerChatScreen extends StatefulWidget {
  const WorkerChatScreen({super.key});

  @override
  State<WorkerChatScreen> createState() => _WorkerChatScreenState();
}

class _WorkerChatScreenState extends State<WorkerChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadWorkerChats();
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
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: vm.loadWorkerChats,
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.workerChats.isEmpty
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
                  itemCount: vm.workerChats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = vm.workerChats[index];
                    final profile = Map<String, dynamic>.from(
                      chat['profiles'] ?? {},
                    );

                    final chatId = (chat['id'] ?? '').toString();
                    final userName = (profile['full_name'] ?? 'Customer')
                        .toString();
                    final userPhone = (profile['phone'] ?? '').toString();
                    final unreadCount = (chat['unread_count'] ?? 0) as int;
                    final lastMessage = (chat['last_message'] ?? '').toString();

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        if (chatId.isEmpty) return;

                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              chatId: chatId,
                              title: userName,
                              subtitle: userPhone.isEmpty
                                  ? 'Customer'
                                  : userPhone,
                            ),
                          ),
                        );

                        if (!mounted) return;
                        await context.read<ChatViewModel>().loadWorkerChats();
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
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'C',
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
                                    userName,
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
                                        : (userPhone.isNotEmpty
                                              ? userPhone
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
