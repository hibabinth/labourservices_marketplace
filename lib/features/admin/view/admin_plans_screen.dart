import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';

class AdminPlansScreen extends StatefulWidget {
  const AdminPlansScreen({super.key});

  @override
  State<AdminPlansScreen> createState() => _AdminPlansScreenState();
}

class _AdminPlansScreenState extends State<AdminPlansScreen> {
  String selectedTab = 'active';

  final tabs = const [
    {'label': 'Active', 'value': 'active'},
    {'label': 'Trial', 'value': 'trial'},
    {'label': 'Expired', 'value': 'expired'},
    {'label': 'Payments', 'value': 'payments'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminViewModel>().loadAdminPlans();
    });
  }

  Future<void> _reload() async {
    await context.read<AdminViewModel>().loadAdminPlans();
  }

  String _text(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return '-';

    final date = DateTime.tryParse(raw);
    if (date == null) return raw;

    return '${date.day}/${date.month}/${date.year}';
  }

  List<Map<String, dynamic>> _currentList(AdminViewModel vm) {
    switch (selectedTab) {
      case 'trial':
        return vm.trialWorkers;
      case 'expired':
        return vm.expiredPlans;
      case 'payments':
        return vm.subscriptionPayments;
      case 'active':
      default:
        return vm.activePlans;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final items = _currentList(vm);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        title: const Text('Plans & Revenue'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C274C),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = selectedTab == tab['value'];

                return ChoiceChip(
                  label: Text(tab['label']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF7A1A),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1C274C),
                    fontWeight: FontWeight.w800,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedTab = tab['value']!;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null &&
                        vm.errorMessage!.trim().isNotEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 120),
                        Text(
                          vm.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    )
                  : items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 140),
                        Center(
                          child: Text(
                            'No records found',
                            style: TextStyle(
                              color: Color(0xFF7A8599),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        if (selectedTab == 'payments') {
                          return _PaymentCard(
                            item: item,
                            text: _text,
                            formatDate: _formatDate,
                          );
                        }

                        return _SubscriptionCard(
                          item: item,
                          text: _text,
                          formatDate: _formatDate,
                          status: selectedTab,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String Function(dynamic value, {String fallback}) text;
  final String Function(dynamic value) formatDate;
  final String status;

  const _SubscriptionCard({
    required this.item,
    required this.text,
    required this.formatDate,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'trial':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return const Color(0xFFFF7A1A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final worker = item['worker_profiles'] as Map<String, dynamic>?;
    final plan = item['subscription_plans'] as Map<String, dynamic>?;

    final workerName = text(worker?['full_name'], fallback: 'Worker');
    final phone = text(worker?['phone']);
    final category = text(worker?['category']);
    final location = text(worker?['location']);
    final planName = text(
      plan?['name'],
      fallback: status == 'trial' ? 'Free Trial' : 'Plan',
    );
    final price = text(plan?['price'], fallback: '0');
    final duration = text(plan?['duration_days'], fallback: '-');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFE1C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFE8D6),
                child: Icon(Icons.workspace_premium, color: _statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  workerName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C274C),
                  ),
                ),
              ),
              Chip(
                label: Text(status.toUpperCase()),
                backgroundColor: _statusColor.withOpacity(0.12),
                labelStyle: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Phone: $phone'),
          Text('Category: $category'),
          Text('Location: $location'),
          const Divider(height: 24),
          Text('Plan: $planName'),
          Text('Price: ₹$price'),
          Text('Duration: $duration days'),
          Text('Start: ${formatDate(item['start_date'])}'),
          Text('End: ${formatDate(item['end_date'])}'),
          if (status == 'trial')
            Text(
              'Trial usage: ${text(item['used_trial_bookings'], fallback: '0')} / ${text(item['trial_booking_limit'], fallback: '2')}',
            ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String Function(dynamic value, {String fallback}) text;
  final String Function(dynamic value) formatDate;

  const _PaymentCard({
    required this.item,
    required this.text,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final worker = item['worker_profiles'] as Map<String, dynamic>?;
    final plan = item['subscription_plans'] as Map<String, dynamic>?;

    final workerName = text(worker?['full_name'], fallback: 'Worker');
    final phone = text(worker?['phone']);
    final category = text(worker?['category']);
    final planName = text(plan?['name'], fallback: 'Subscription Plan');
    final status = text(item['payment_status'], fallback: 'pending');

    final isPaid = status.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFE8D6),
                child: Icon(Icons.currency_rupee, color: Color(0xFFFF7A1A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '₹${text(item['amount'], fallback: '0')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C274C),
                  ),
                ),
              ),
              Chip(
                label: Text(status.toUpperCase()),
                backgroundColor: isPaid
                    ? Colors.green.withOpacity(0.12)
                    : Colors.orange.withOpacity(0.12),
                labelStyle: TextStyle(
                  color: isPaid ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Worker: $workerName'),
          Text('Phone: $phone'),
          Text('Category: $category'),
          Text('Plan: $planName'),
          Text('Payment ID: ${text(item['payment_id'])}'),
          Text('Date: ${formatDate(item['created_at'])}'),
        ],
      ),
    );
  }
}
