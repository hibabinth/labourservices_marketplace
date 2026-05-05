import 'package:flutter/material.dart';
import 'package:labour_service/features/worker/viewmodel/worker_booking_viewmodel.dart';
import 'package:provider/provider.dart';

class WorkerBookingScreen extends StatefulWidget {
  const WorkerBookingScreen({super.key});

  @override
  State<WorkerBookingScreen> createState() => _WorkerBookingScreenState();
}

class _WorkerBookingScreenState extends State<WorkerBookingScreen> {
  final List<Map<String, String>> tabs = const [
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerBookingViewModel>().loadWorkerBookings();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'working':
        return Colors.orange;
      case 'completed':
        return Colors.teal;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return const Color(0xFF1E63F3);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'working':
        return 'Working';
      case 'completed':
        return 'Completed';
      case 'declined':
        return 'Declined';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Future<void> _handleAction({
    required BuildContext context,
    required WorkerBookingViewModel vm,
    required String bookingId,
    required String status,
    required String failMessage,
  }) async {
    final ok = await vm.updateStatus(bookingId: bookingId, status: status);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Booking updated successfully'
              : (vm.errorMessage ?? failMessage),
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required BuildContext context,
    required WorkerBookingViewModel vm,
    required String bookingId,
    required String status,
  }) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleAction(
                context: context,
                vm: vm,
                bookingId: bookingId,
                status: 'accepted',
                failMessage: 'Failed to accept booking',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleAction(
                context: context,
                vm: vm,
                bookingId: bookingId,
                status: 'declined',
                failMessage: 'Failed to decline booking',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Decline'),
            ),
          ),
        ],
      );
    }

    if (status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleAction(
            context: context,
            vm: vm,
            bookingId: bookingId,
            status: 'working',
            failMessage: 'Failed to start work',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Start Work'),
        ),
      );
    }

    if (status == 'working') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleAction(
            context: context,
            vm: vm,
            bookingId: bookingId,
            status: 'completed',
            failMessage: 'Failed to complete work',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Mark Completed'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkerBookingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text(
          'Worker Bookings',
          style: TextStyle(color: Color(0xFF1C274C)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  final label = tab['label']!;
                  final value = tab['value']!;
                  final isSelected = vm.selectedStatus == value;

                  return GestureDetector(
                    onTap: () => vm.changeTab(value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E63F3)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E63F3)
                              : const Color(0xFFE3E8F2),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1C274C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    vm.loadWorkerBookings(status: vm.selectedStatus),
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.bookings.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No ${vm.selectedStatus == 'all' ? '' : vm.selectedStatus} bookings found.',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF7A8599),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: vm.bookings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final booking = vm.bookings[index];
                          final status = (booking['status'] ?? 'pending')
                              .toString();
                          final bookingId = booking['id'].toString();

                          final userName = (booking['user_name'] ?? 'Customer')
                              .toString();
                          final userPhone =
                              (booking['user_phone'] ?? 'No phone').toString();

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1C274C),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(
                                          status,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        _statusLabel(status),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _statusColor(status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Phone: $userPhone',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7A8599),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Date: ${(booking['booking_date'] ?? '').toString()}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Address: ${(booking['booking_address'] ?? '').toString()}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Note: ${(booking['booking_note'] ?? '').toString()}',
                                ),
                                const SizedBox(height: 14),
                                _buildActionButtons(
                                  context: context,
                                  vm: vm,
                                  bookingId: bookingId,
                                  status: status,
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
      ),
    );
  }
}
