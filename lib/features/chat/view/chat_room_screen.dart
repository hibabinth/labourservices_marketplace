import 'package:flutter/material.dart';
import 'package:labour_service/features/chat/viewmodel/chat_room_viewmodel.dart';
import 'package:provider/provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String title;
  final String subtitle;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.title,
    required this.subtitle,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatRoomViewModel? _vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vm ??= context.read<ChatRoomViewModel>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ChatRoomViewModel>();
      await vm.loadMessages(widget.chatId);
      await vm.subscribeToMessages(widget.chatId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _vm?.disposeSubscription();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    await _vm?.markSeenAndRefresh(widget.chatId);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return '';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final vm = context.read<ChatRoomViewModel>();
    final ok = await vm.sendMessage(chatId: widget.chatId, message: text);

    if (!mounted) return;

    if (ok) {
      _messageController.clear();
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Failed to send message')),
      );
    }
  }

  Future<void> _showEditDialog({
    required String messageId,
    required String currentText,
  }) async {
    final controller = TextEditingController(text: currentText);

    final newText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit message'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Update your message'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (newText == null || newText.isEmpty) return;

    final ok = await context.read<ChatRoomViewModel>().updateMessage(
      chatId: widget.chatId,
      messageId: messageId,
      newMessage: newText,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ChatRoomViewModel>().errorMessage ??
                'Failed to edit message',
          ),
        ),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete message'),
          content: const Text('Do you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;

    final ok = await context.read<ChatRoomViewModel>().deleteMessage(
      chatId: widget.chatId,
      messageId: messageId,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ChatRoomViewModel>().errorMessage ??
                'Failed to delete message',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatRoomViewModel>();
    final currentUserId = vm.currentUserId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          leading: IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFF1C274C),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                widget.subtitle,
                style: const TextStyle(color: Color(0xFF7A8599), fontSize: 12),
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
        ),
        body: Column(
          children: [
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.messages.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages yet. Start the conversation.',
                        style: TextStyle(color: Color(0xFF7A8599)),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.messages.length,
                      itemBuilder: (context, index) {
                        final message = vm.messages[index];
                        final senderId = (message['sender_id'] ?? '')
                            .toString();
                        final messageId = (message['id'] ?? '').toString();
                        final text = (message['message'] ?? '').toString();
                        final isEdited =
                            (message['is_edited'] ?? false) == true;
                        final seenAt = (message['seen_at'] ?? '').toString();
                        final createdAt = (message['created_at'] ?? '')
                            .toString();
                        final isMe = senderId == currentUserId;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: isMe
                                ? () async {
                                    final action =
                                        await showModalBottomSheet<String>(
                                          context: context,
                                          builder: (context) {
                                            return SafeArea(
                                              child: Wrap(
                                                children: [
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.edit,
                                                    ),
                                                    title: const Text(
                                                      'Edit message',
                                                    ),
                                                    onTap: () => Navigator.pop(
                                                      context,
                                                      'edit',
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                    ),
                                                    title: const Text(
                                                      'Delete message',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    onTap: () => Navigator.pop(
                                                      context,
                                                      'delete',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );

                                    if (!mounted) return;

                                    if (action == 'edit') {
                                      await _showEditDialog(
                                        messageId: messageId,
                                        currentText: text,
                                      );
                                    } else if (action == 'delete') {
                                      await _deleteMessage(messageId);
                                    }
                                  }
                                : null,
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 280,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? const Color(0xFF1E63F3)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : const Color(0xFF1C274C),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 6,
                                    right: 6,
                                    bottom: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(createdAt),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF7A8599),
                                        ),
                                      ),
                                      if (isEdited) ...[
                                        const SizedBox(width: 6),
                                        const Text(
                                          'edited',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF7A8599),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                      if (isMe) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          seenAt.isNotEmpty ? 'Seen' : 'Sent',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: seenAt.isNotEmpty
                                                ? Colors.green
                                                : const Color(0xFF7A8599),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: vm.isSending ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E63F3),
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: vm.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
