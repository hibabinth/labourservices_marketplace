import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/worker_home_viewmodel.dart';
import 'worker_booking_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerHomeViewModel>().loadDashboard();
    });
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value.contains('active') || value.contains('available')) {
      return Colors.green;
    }
    if (value.contains('busy') || value.contains('working')) {
      return Colors.orange;
    }
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerHomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: vm.loadDashboard,
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderSection(
                        pendingCount: vm.pendingBookings,
                        onNotificationTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkerBookingScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      _HeroCard(
                        todayJobs: vm.todayJobs,
                        completedToday: vm.completedToday,
                        workerStatus: vm.workerStatus,
                        statusColor: _statusColor(vm.workerStatus),
                      ),
                      const SizedBox(height: 24),

                      const _SectionTitle(title: 'Overview'),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _ModernStatCard(
                            title: 'Booking Requests',
                            value: vm.pendingBookings.toString(),
                            icon: Icons.notifications_active_outlined,
                            accent: const Color(0xFF1E63F3),
                          ),
                          _ModernStatCard(
                            title: 'Unread Chats',
                            value: vm.unreadChats.toString(),
                            icon: Icons.chat_bubble_outline_rounded,
                            accent: const Color(0xFF7C4DFF),
                          ),
                          _ModernStatCard(
                            title: 'Completed Today',
                            value: vm.completedToday.toString(),
                            icon: Icons.task_alt_rounded,
                            accent: const Color(0xFF00A86B),
                          ),
                          _ModernStatCard(
                            title: 'Worker Status',
                            value: vm.workerStatus,
                            icon: Icons.verified_outlined,
                            accent: _statusColor(vm.workerStatus),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Today Performance'),
                      const SizedBox(height: 12),

                      _TodayPerformanceCard(
                        todayJobs: vm.todayJobs,
                        completedToday: vm.completedToday,
                        pendingBookings: vm.pendingBookings,
                        workerStatus: vm.workerStatus,
                        statusColor: _statusColor(vm.workerStatus),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionTitle(title: 'Latest Booking Requests'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WorkerBookingScreen(),
                                ),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (vm.recentPendingBookings.isEmpty)
                        const _EmptyRequestCard()
                      else
                        ...vm.recentPendingBookings.map(
                          (booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BookingPreviewCard(booking: booking),
                          ),
                        ),

                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Quick Actions'),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.02,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _QuickActionCard(
                            icon: Icons.person_outline_rounded,
                            title: 'Profile Setup',
                            subtitle: 'Update worker bio, skills and identity',
                            accent: const Color(0xFF1E63F3),
                            badgeText: 'Important',
                            onTap: () {},
                          ),
                          _QuickActionCard(
                            icon: Icons.category_outlined,
                            title: 'Service Category',
                            subtitle: 'Manage your job category and expertise',
                            accent: const Color(0xFF8E44AD),
                            badgeText: 'Manage',
                            onTap: () {},
                          ),
                          _QuickActionCard(
                            icon: Icons.schedule_rounded,
                            title: 'Availability',
                            subtitle: 'Set status, work time and availability',
                            accent: const Color(0xFF00A86B),
                            badgeText: vm.workerStatus,
                            onTap: () {},
                          ),
                          _QuickActionCard(
                            icon: Icons.work_history_outlined,
                            title: 'Bookings',
                            subtitle:
                                'Track requests, working jobs and history',
                            accent: const Color(0xFFFF9800),
                            badgeText: '${vm.pendingBookings} New',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WorkerBookingScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1C274C),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onNotificationTap;

  const _HeaderSection({
    required this.pendingCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E63F3), Color(0xFF4D8DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.engineering_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(fontSize: 13, color: Color(0xFF7A8599)),
              ),
              SizedBox(height: 4),
              Text(
                'Worker Dashboard',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C274C),
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1C274C),
                ),
              ),
            ),
            if (pendingCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pendingCount > 99 ? '99+' : '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int todayJobs;
  final int completedToday;
  final String workerStatus;
  final Color statusColor;

  const _HeroCard({
    required this.todayJobs,
    required this.completedToday,
    required this.workerStatus,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFF1E63F3).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Worker Panel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You have $todayJobs job(s) today and completed $completedToday work(s). Keep your status updated to receive more bookings.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 5, backgroundColor: statusColor),
                const SizedBox(width: 8),
                Text(
                  'Current Status: $workerStatus',
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
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7A8599)),
          ),
        ],
      ),
    );
  }
}

class _TodayPerformanceCard extends StatelessWidget {
  final int todayJobs;
  final int completedToday;
  final int pendingBookings;
  final String workerStatus;
  final Color statusColor;

  const _TodayPerformanceCard({
    required this.todayJobs,
    required this.completedToday,
    required this.pendingBookings,
    required this.workerStatus,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _PerformanceRow(
            label: 'Today Jobs',
            value: '$todayJobs',
            color: const Color(0xFF1E63F3),
          ),
          const SizedBox(height: 12),
          _PerformanceRow(
            label: 'Completed Works',
            value: '$completedToday',
            color: const Color(0xFF00A86B),
          ),
          const SizedBox(height: 12),
          _PerformanceRow(
            label: 'Pending Requests',
            value: '$pendingBookings',
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(height: 12),
          _PerformanceRow(
            label: 'Worker Status',
            value: workerStatus,
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PerformanceRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

class _BookingPreviewCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingPreviewCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final userName = (booking['user_name'] ?? 'Customer').toString();
    final address = (booking['booking_address'] ?? 'No address').toString();
    final date = (booking['booking_date'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Color(0xFF1E63F3),
            ),
          ),
          const SizedBox(width: 14),
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
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A8599),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: $date',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8599),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                color: Color(0xFF1E63F3),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRequestCard extends StatelessWidget {
  const _EmptyRequestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        'No new booking requests.',
        style: TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String badgeText;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accent),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C274C),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A8599),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
