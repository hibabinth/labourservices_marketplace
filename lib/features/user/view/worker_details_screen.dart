import 'package:flutter/material.dart';
import 'package:labour_service/features/chat/repository/chat_repository.dart';
import 'package:labour_service/features/chat/view/chat_room_screen.dart';
import 'package:labour_service/features/user/view/booking_screen.dart';
import 'package:labour_service/features/user/viewmodel/service_viewmodel.dart';
import 'package:provider/provider.dart';

class WorkerDetailsScreen extends StatefulWidget {
  final String workerId;

  const WorkerDetailsScreen({super.key, required this.workerId});

  @override
  State<WorkerDetailsScreen> createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceViewModel>().loadWorkerDetails(widget.workerId);
    });
  }

  Future<void> _openChat(Map<String, dynamic> worker) async {
    try {
      final chatRepository = context.read<ChatRepository>();
      final currentUserId = chatRepository.currentUserId;

      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      final chatId = await chatRepository.getOrCreateChat(
        userId: currentUserId,
        workerId: widget.workerId,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            title: (worker['full_name'] ?? 'Worker').toString(),
            subtitle: (worker['category'] ?? '').toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
    }
  }

  Color _availabilityColor(String value) {
    final status = value.toLowerCase();
    if (status.contains('available') || status.contains('active')) {
      return Colors.green;
    }
    if (status.contains('busy') || status.contains('working')) {
      return Colors.orange;
    }
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceViewModel>();
    final worker = vm.selectedWorker;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        elevation: 0,
        title: const Text(
          'Worker Details',
          style: TextStyle(
            color: Color(0xFF1C274C),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : worker == null
            ? const Center(
                child: Text(
                  'Worker details not found.',
                  style: TextStyle(color: Color(0xFF7A8599)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  children: [
                    _TopProfileCard(
                      imageUrl: (worker['avatar_url'] ?? '').toString(),
                      fullName: (worker['full_name'] ?? 'Unknown Worker')
                          .toString(),
                      category: (worker['category'] ?? 'General Worker')
                          .toString(),
                      rate: (worker['rate'] ?? 'N/A').toString(),
                      availability: (worker['availability'] ?? 'Unavailable')
                          .toString(),
                      availabilityColor: _availabilityColor(
                        (worker['availability'] ?? 'Unavailable').toString(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _MiniInfoCard(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            value: (worker['location'] ?? 'Not added')
                                .toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniInfoCard(
                            icon: Icons.work_outline_rounded,
                            title: 'Experience',
                            value:
                                '${(worker['experience_years'] ?? 0).toString()} years',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _DetailsSectionCard(
                      title: 'Professional Information',
                      children: [
                        _InfoRow(
                          label: 'Phone',
                          value: (worker['phone'] ?? 'Not added').toString(),
                        ),
                        _InfoRow(
                          label: 'Skills',
                          value: (worker['skills'] ?? 'Not added').toString(),
                        ),
                        _InfoRow(
                          label: 'Availability',
                          value: (worker['availability'] ?? 'Not added')
                              .toString(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _DetailsSectionCard(
                      title: 'About Worker',
                      children: [
                        Text(
                          (worker['bio'] ?? 'No bio added').toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF53627C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () => _openChat(worker),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text(
                                'Chat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1E63F3),
                                side: const BorderSide(
                                  color: Color(0xFF1E63F3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BookingScreen(worker: worker),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E63F3),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: const Text(
                                'Book Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TopProfileCard extends StatelessWidget {
  final String imageUrl;
  final String fullName;
  final String category;
  final String rate;
  final String availability;
  final Color availabilityColor;

  const _TopProfileCard({
    required this.imageUrl,
    required this.fullName,
    required this.category,
    required this.rate,
    required this.availability,
    required this.availabilityColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E63F3), Color(0xFF4D8DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E63F3).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ProfileFallback(),
                    )
                  : const _ProfileFallback(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹$rate',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: availabilityColor),
                    const SizedBox(width: 8),
                    Text(
                      availability,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileFallback extends StatelessWidget {
  const _ProfileFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.person, size: 42, color: Colors.white),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1E63F3)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7A8599),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C274C),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailsSectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C274C),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A8599),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C274C),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
