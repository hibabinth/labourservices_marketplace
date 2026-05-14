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
  static const Color orange = Color(0xFFFF7A1A);
  static const Color lightOrange = Color(0xFFFFE8D6);
  static const Color bg = Color(0xFFFFF8F2);
  static const Color dark = Color(0xFF1C274C);
  static const Color muted = Color(0xFF7A8599);

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
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: Colors.white,
            ),
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

  void _openPlans() {
    final state = context.findAncestorStateOfType<State>();
    Navigator.pushNamed(context, '/admin-home');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: orange,
          child: _buildBody(context, vm),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminViewModel vm) {
    if (vm.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 240),
          Center(child: CircularProgressIndicator(color: orange)),
        ],
      );
    }

    if (vm.errorMessage != null && vm.errorMessage!.trim().isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Failed to load dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: dark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            vm.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: muted),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
              onPressed: _refreshDashboard,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        _HeaderCard(
          revenue: vm.totalRevenue,
          onLogout: () => _showLogoutDialog(context),
        ),
        const SizedBox(height: 18),

        _SectionHeader(
          title: 'Overview',
          subtitle: 'Your platform performance',
          actionText: 'Refresh',
          onTap: _refreshDashboard,
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'Bookings',
              value: vm.totalBookings.toString(),
              subtitle: 'All services',
              icon: Icons.calendar_month_outlined,
              onTap: () => Navigator.pushNamed(context, '/admin-bookings'),
            ),
            _StatCard(
              title: 'Users',
              value: vm.totalUsers.toString(),
              subtitle: 'Customers',
              icon: Icons.people_alt_outlined,
              onTap: () => Navigator.pushNamed(context, '/admin-users'),
            ),
            _StatCard(
              title: 'Workers',
              value: vm.totalWorkers.toString(),
              subtitle: 'Providers',
              icon: Icons.engineering_outlined,
              onTap: () => Navigator.pushNamed(context, '/admin-workers'),
            ),
            _StatCard(
              title: 'Revenue',
              value: '₹${vm.totalRevenue.toStringAsFixed(0)}',
              subtitle: 'Subscriptions',
              icon: Icons.currency_rupee,
            ),
          ],
        ),

        const SizedBox(height: 18),

        _RevenueGraphCard(totalRevenue: vm.totalRevenue),

        const SizedBox(height: 18),

        _SectionHeader(
          title: 'Bookings Status',
          subtitle: 'Service request summary',
          actionText: 'View all',
          onTap: () => Navigator.pushNamed(context, '/admin-bookings'),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _SmallStatusCard(
                title: 'Pending',
                value: vm.pendingBookings.toString(),
                icon: Icons.pending_actions_outlined,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SmallStatusCard(
                title: 'Completed',
                value: vm.completedBookings.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _SectionHeader(
          title: 'Subscription Plans',
          subtitle: 'Worker plan status',
          actionText: 'Plans',
          onTap: () {},
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _PlanMiniCard(
                title: 'Active',
                value: vm.activeSubscriptions.toString(),
                icon: Icons.workspace_premium_outlined,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PlanMiniCard(
                title: 'Trial',
                value: vm.trialSubscriptions.toString(),
                icon: Icons.card_giftcard_outlined,
                color: orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PlanMiniCard(
                title: 'Expired',
                value: vm.expiredSubscriptions.toString(),
                icon: Icons.event_busy_outlined,
                color: Colors.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _SectionHeader(
          title: 'Recent Bookings',
          subtitle: 'Latest service requests',
          actionText: 'View all',
          onTap: () => Navigator.pushNamed(context, '/admin-bookings'),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          child: vm.recentBookings.isEmpty
              ? const _EmptyState(message: 'No recent bookings found')
              : Column(
                  children: vm.recentBookings.map((booking) {
                    final status = (booking['status'] ?? 'pending').toString();
                    final serviceTitle = (booking['service_title'] ?? 'Service')
                        .toString();
                    final userName = (booking['user_name'] ?? '-').toString();
                    final workerName = (booking['worker_name'] ?? '-')
                        .toString();
                    final amount = (booking['payment_amount'] ?? 0).toString();

                    return _InfoTile(
                      icon: Icons.calendar_today_outlined,
                      title: serviceTitle,
                      subtitle: '$userName → $workerName',
                      bottomText: '₹$amount',
                      trailing: _StatusChip(label: status),
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 18),

        _SectionHeader(
          title: 'Recent Workers',
          subtitle: 'Newly joined workers',
          actionText: 'View all',
          onTap: () => Navigator.pushNamed(context, '/admin-workers'),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          child: vm.recentWorkers.isEmpty
              ? const _EmptyState(message: 'No recent workers found')
              : Column(
                  children: vm.recentWorkers.map((worker) {
                    final name = (worker['full_name'] ?? '-').toString();
                    final category = (worker['category'] ?? '-').toString();
                    final location = (worker['location'] ?? '-').toString();
                    final isComplete =
                        (worker['is_profile_complete'] as bool?) ?? false;

                    return _InfoTile(
                      icon: Icons.engineering_outlined,
                      title: name,
                      subtitle: '$category • $location',
                      bottomText: isComplete
                          ? 'Profile complete'
                          : 'Incomplete profile',
                      trailing: _StatusChip(
                        label: isComplete ? 'Complete' : 'Incomplete',
                        isSuccess: isComplete,
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final double revenue;
  final VoidCallback onLogout;

  const _HeaderCard({required this.revenue, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1A), Color(0xFFFFA24D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A1A).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Color(0xFFFF7A1A),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Welcome, Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Subscription Revenue',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${revenue.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track bookings, workers, subscriptions and payments.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C274C),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A8599),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: Color(0xFFFF7A1A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFE1C7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFE8D6),
                child: Icon(icon, color: const Color(0xFFFF7A1A), size: 22),
              ),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C274C),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C274C),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A8599)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevenueGraphCard extends StatelessWidget {
  final double totalRevenue;

  const _RevenueGraphCard({required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    final values = [
      totalRevenue * 0.25,
      totalRevenue * 0.45,
      totalRevenue * 0.35,
      totalRevenue * 0.7,
      totalRevenue * 0.55,
      totalRevenue,
    ];

    final maxValue = values.fold<double>(1, (max, v) => v > max ? v : max);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFFE1C7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Graph',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C274C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Subscription revenue overview',
            style: TextStyle(color: Color(0xFF7A8599)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final heightFactor = values[index] / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 120 * heightFactor.clamp(0.08, 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7A1A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ['M1', 'M2', 'M3', 'M4', 'M5', 'Now'][index],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7A8599),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallStatusCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE1C7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C274C),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7A8599),
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

class _PlanMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PlanMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE1C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C274C),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7A8599),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE1C7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String bottomText;
  final Widget trailing;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bottomText,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFE8D6),
            child: Icon(icon, color: const Color(0xFFFF7A1A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C274C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF7A8599)),
                ),
                const SizedBox(height: 3),
                Text(
                  bottomText,
                  style: const TextStyle(
                    color: Color(0xFFFF7A1A),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
    final color = isSuccess ? Colors.green : _color(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Color _color(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
      case 'active':
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'working':
      case 'trial':
        return Colors.orange;
      case 'declined':
      case 'expired':
      case 'failed':
        return Colors.red;
      default:
        return const Color(0xFFFF7A1A);
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
