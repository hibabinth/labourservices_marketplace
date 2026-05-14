import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  static const Color orange = Color(0xFFFF7A1A);
  static const Color bg = Color(0xFFFFF8F2);
  static const Color dark = Color(0xFF1C274C);
  static const Color muted = Color(0xFF7A8599);

  String selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> filters = const [
    {'label': 'All', 'value': 'all'},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Accepted', 'value': 'accepted'},
    {'label': 'Working', 'value': 'working'},
    {'label': 'Completed', 'value': 'completed'},
    {'label': 'Declined', 'value': 'declined'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminViewModel>().loadAdminBookings(status: selectedStatus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<AdminViewModel>().loadAdminBookings(
      status: selectedStatus,
    );
  }

  String _text(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'accepted':
        return Colors.teal;
      case 'working':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return orange;
    }
  }

  Color _paymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.orange;
      case 'unpaid':
      default:
        return orange;
    }
  }

  List<Map<String, dynamic>> _filteredBookings(
    List<Map<String, dynamic>> list,
  ) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return list;

    return list.where((b) {
      final service = _text(b['service_title']).toLowerCase();
      final user = _text(b['user_name']).toLowerCase();
      final worker = _text(b['worker_name']).toLowerCase();
      final category = _text(b['worker_category']).toLowerCase();
      final status = _text(b['status']).toLowerCase();

      return service.contains(query) ||
          user.contains(query) ||
          worker.contains(query) ||
          category.contains(query) ||
          status.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final bookings = _filteredBookings(vm.adminBookings);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              total: vm.adminBookings.length,
              selectedStatus: selectedStatus,
              onRefresh: _reload,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: _SearchBox(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              height: 58,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = filters[index];
                  final isSelected = selectedStatus == item['value'];

                  return ChoiceChip(
                    label: Text(item['label']!),
                    selected: isSelected,
                    selectedColor: orange,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? orange : const Color(0xFFFFE1C7),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : dark,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (_) async {
                      setState(() {
                        selectedStatus = item['value']!;
                      });
                      await _reload();
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: orange,
                onRefresh: _reload,
                child: vm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: orange),
                      )
                    : vm.errorMessage != null &&
                          vm.errorMessage!.trim().isNotEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 100),
                          Text(
                            vm.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      )
                    : bookings.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 140),
                          Center(
                            child: Text(
                              'No bookings found',
                              style: TextStyle(
                                color: muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: bookings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final b = bookings[index];

                          final status = _text(
                            b['status'],
                            fallback: 'pending',
                          );
                          final paymentStatus = _text(
                            b['payment_status'],
                            fallback: 'unpaid',
                          );

                          return _BookingCard(
                            serviceTitle: _text(
                              b['service_title'],
                              fallback: 'Service Booking',
                            ),
                            userName: _text(b['user_name']),
                            userPhone: _text(b['user_phone']),
                            workerName: _text(b['worker_name']),
                            workerPhone: _text(b['worker_phone']),
                            category: _text(b['worker_category']),
                            date: _text(b['booking_date']),
                            time: _text(b['booking_time']),
                            address: _text(b['booking_address']),
                            urgency: _text(b['urgency']),
                            amount: _text(b['payment_amount'], fallback: '0'),
                            status: status,
                            paymentStatus: paymentStatus,
                            statusColor: _statusColor(status),
                            paymentColor: _paymentColor(paymentStatus),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;
  final String selectedStatus;
  final Future<void> Function() onRefresh;

  const _Header({
    required this.total,
    required this.selectedStatus,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1A), Color(0xFFFFA24D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A1A).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.calendar_month, color: Color(0xFFFF7A1A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Bookings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total ${selectedStatus == 'all' ? 'total' : selectedStatus} bookings',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search service, user, worker, category...',
        prefixIcon: const Icon(Icons.search, color: Color(0xFFFF7A1A)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFFE1C7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFFE1C7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFF7A1A), width: 1.4),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String serviceTitle;
  final String userName;
  final String userPhone;
  final String workerName;
  final String workerPhone;
  final String category;
  final String date;
  final String time;
  final String address;
  final String urgency;
  final String amount;
  final String status;
  final String paymentStatus;
  final Color statusColor;
  final Color paymentColor;

  const _BookingCard({
    required this.serviceTitle,
    required this.userName,
    required this.userPhone,
    required this.workerName,
    required this.workerPhone,
    required this.category,
    required this.date,
    required this.time,
    required this.address,
    required this.urgency,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.statusColor,
    required this.paymentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFE8D6),
                child: Icon(Icons.handyman_outlined, color: Color(0xFFFF7A1A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  serviceTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C274C),
                  ),
                ),
              ),
              Text(
                '₹$amount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF7A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoLine(
            icon: Icons.person_outline,
            text: 'User: $userName • $userPhone',
          ),
          _InfoLine(
            icon: Icons.engineering_outlined,
            text: 'Worker: $workerName • $workerPhone',
          ),
          _InfoLine(icon: Icons.category_outlined, text: 'Category: $category'),
          _InfoLine(icon: Icons.schedule_outlined, text: '$date at $time'),
          _InfoLine(icon: Icons.location_on_outlined, text: address),
          _InfoLine(
            icon: Icons.priority_high_outlined,
            text: 'Urgency: $urgency',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Chip(label: status.toUpperCase(), color: statusColor),
              const SizedBox(width: 8),
              _Chip(label: paymentStatus.toUpperCase(), color: paymentColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFFF7A1A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF53627C),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
