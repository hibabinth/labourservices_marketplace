import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/admin_viewmodel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadDashboard();
    });
  }

  Future<void> _refreshDashboard() async {
    await context.read<AdminViewModel>().loadDashboard();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AuthViewModel>().signOut();

              if (!mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C274C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _buildBody(context, vm),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminViewModel vm) {
    if (vm.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (vm.errorMessage != null && vm.errorMessage!.trim().isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Failed to load dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C274C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            vm.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _refreshDashboard,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Welcome, Admin',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C274C),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Monitor users, workers, bookings, revenue, and subscriptions.',
          style: TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
        ),
        const SizedBox(height: 20),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _DashboardActionCard(
              onTap: () => Navigator.pushNamed(context, '/admin-users'),
              child: _StatCard(
                title: 'Users',
                value: vm.totalUsers.toString(),
                subtitle: 'Registered customers',
                icon: Icons.people_alt_outlined,
              ),
            ),
            _DashboardActionCard(
              onTap: () => Navigator.pushNamed(context, '/admin-workers'),
              child: _StatCard(
                title: 'Workers',
                value: vm.totalWorkers.toString(),
                subtitle: 'Service providers',
                icon: Icons.engineering_outlined,
              ),
            ),
            _DashboardActionCard(
              onTap: () => Navigator.pushNamed(context, '/admin-bookings'),
              child: _StatCard(
                title: 'Bookings',
                value: vm.totalBookings.toString(),
                subtitle: 'All service bookings',
                icon: Icons.calendar_month_outlined,
              ),
            ),
            _StatCard(
              title: 'Pending',
              value: vm.pendingBookings.toString(),
              subtitle: 'Pending bookings',
              icon: Icons.pending_actions_outlined,
            ),
            _StatCard(
              title: 'Completed',
              value: vm.completedBookings.toString(),
              subtitle: 'Completed bookings',
              icon: Icons.check_circle_outline,
            ),
            _StatCard(
              title: 'Worker Reviews',
              value: vm.incompleteWorkerProfiles.toString(),
              subtitle: 'Incomplete profiles',
              icon: Icons.assignment_late_outlined,
            ),

            // ✅ NEW REVENUE / SUBSCRIPTION CARDS
            _StatCard(
              title: 'Revenue',
              value: '₹${vm.totalRevenue.toStringAsFixed(0)}',
              subtitle: 'Total subscription income',
              icon: Icons.currency_rupee,
            ),
            _StatCard(
              title: 'Active Plans',
              value: vm.activeSubscriptions.toString(),
              subtitle: 'Paid subscriptions',
              icon: Icons.workspace_premium_outlined,
            ),
            _StatCard(
              title: 'Trial Workers',
              value: vm.trialSubscriptions.toString(),
              subtitle: 'Free trial workers',
              icon: Icons.card_giftcard_outlined,
            ),
            _StatCard(
              title: 'Expired Plans',
              value: vm.expiredSubscriptions.toString(),
              subtitle: 'Expired subscriptions',
              icon: Icons.event_busy_outlined,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _SectionCard(
          title: 'Recent Bookings',
          child: vm.recentBookings.isEmpty
              ? const _EmptyState(message: 'No recent bookings found')
              : Column(
                  children: vm.recentBookings.map((booking) {
                    final status = (booking['status'] ?? 'unknown').toString();
                    final serviceTitle = (booking['service_title'] ?? '-')
                        .toString();
                    final userName = (booking['user_name'] ?? '-').toString();
                    final workerName = (booking['worker_name'] ?? '-')
                        .toString();
                    final amount = (booking['payment_amount'] ?? 0).toString();
                    final urgency = (booking['urgency'] ?? '-').toString();

                    return _InfoTile(
                      title: serviceTitle,
                      subtitle:
                          'User: $userName\nWorker: $workerName\nUrgency: $urgency',
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StatusChip(label: status),
                          const SizedBox(height: 6),
                          Text(
                            '₹$amount',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C274C),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 16),

        _SectionCard(
          title: 'Recent Workers',
          child: vm.recentWorkers.isEmpty
              ? const _EmptyState(message: 'No recent workers found')
              : Column(
                  children: vm.recentWorkers.map((worker) {
                    final name = (worker['full_name'] ?? '-').toString();
                    final category = (worker['category'] ?? '-').toString();
                    final location = (worker['location'] ?? '-').toString();
                    final availability = (worker['availability'] ?? '-')
                        .toString();
                    final isComplete =
                        (worker['is_profile_complete'] as bool?) ?? false;

                    return _InfoTile(
                      title: name,
                      subtitle:
                          'Category: $category\nLocation: $location\nAvailability: $availability',
                      trailing: _StatusChip(
                        label: isComplete ? 'Complete' : 'Incomplete',
                        isSuccess: isComplete,
                      ),
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _DashboardActionCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: const Color(0xFF1E63F3)),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C274C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C274C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7A8599)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C274C),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C274C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF7A8599),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSuccess;

  const _StatusChip({required this.label, this.isSuccess = false});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSuccess
        ? const Color(0xFFE8F7EE)
        : _getBackgroundColor(label);
    final textColor = isSuccess
        ? const Color(0xFF1E8E5A)
        : _getTextColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Color _getBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFE8F7EE);
      case 'pending':
        return const Color(0xFFFFF4E5);
      case 'accepted':
      case 'working':
        return const Color(0xFFEAF1FF);
      case 'cancelled':
      case 'declined':
        return const Color(0xFFFDECEC);
      default:
        return const Color(0xFFF1F4F9);
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF1E8E5A);
      case 'pending':
        return const Color(0xFFB26A00);
      case 'accepted':
      case 'working':
        return const Color(0xFF1E63F3);
      case 'cancelled':
      case 'declined':
        return const Color(0xFFD93025);
      default:
        return const Color(0xFF6F7C91);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
        ),
      ),
    );
  }
}
