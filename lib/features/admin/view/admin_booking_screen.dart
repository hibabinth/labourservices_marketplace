import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String selectedStatus = 'all';

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
        return Colors.teal;
      case 'accepted':
        return Colors.green;
      case 'working':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return const Color(0xFF1E63F3);
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
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final bookings = vm.adminBookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Admin Bookings'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C274C),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = filters[index];
                final isSelected = selectedStatus == item['value'];

                return ChoiceChip(
                  label: Text(item['label']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E63F3),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1C274C),
                    fontWeight: FontWeight.w700,
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
              onRefresh: _reload,
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
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
                            style: TextStyle(color: Color(0xFF7A8599)),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final b = bookings[index];

                        final status = _text(b['status'], fallback: 'pending');
                        final paymentStatus = _text(
                          b['payment_status'],
                          fallback: 'unpaid',
                        );

                        return Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _text(
                                  b['service_title'],
                                  fallback: 'Service Booking',
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1C274C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('User: ${_text(b['user_name'])}'),
                              Text('Worker: ${_text(b['worker_name'])}'),
                              Text('Category: ${_text(b['worker_category'])}'),
                              Text('Date: ${_text(b['booking_date'])}'),
                              Text('Time: ${_text(b['booking_time'])}'),
                              Text('Address: ${_text(b['booking_address'])}'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(status.toUpperCase()),
                                    backgroundColor: _statusColor(
                                      status,
                                    ).withOpacity(0.12),
                                    labelStyle: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(paymentStatus.toUpperCase()),
                                    backgroundColor: _paymentColor(
                                      paymentStatus,
                                    ).withOpacity(0.12),
                                    labelStyle: TextStyle(
                                      color: _paymentColor(paymentStatus),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${_text(b['payment_amount'], fallback: '0')}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1E63F3),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
