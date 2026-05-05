import 'package:flutter/material.dart';
import 'package:labour_service/features/user/viewmodel/booking_viewmodel.dart';
import 'package:provider/provider.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingViewModel>().loadMyBookings();
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

  Color _paymentColor(String status) {
    switch (status) {
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

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'working':
        return 'Work Started';
      case 'completed':
        return 'Completed';
      case 'declined':
        return 'Declined';
      case 'pending':
      default:
        return 'Pending Approval';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Color(0xFF1C274C)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: vm.loadMyBookings,
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.bookings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Text(
                        'No bookings yet.',
                        style: TextStyle(
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
                    final status = (booking['status'] ?? 'pending').toString();
                    final paymentStatus =
                        (booking['payment_status'] ?? 'unpaid').toString();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (booking['worker_name'] ?? 'Unknown Worker')
                                .toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C274C),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (booking['worker_category'] ?? '').toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A8599),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Service: ${(booking['service_title'] ?? '').toString()}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${(booking['booking_date'] ?? '').toString()}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Time: ${(booking['booking_time'] ?? '').toString()}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Address: ${(booking['booking_address'] ?? '').toString()}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Payment Method: ${(booking['payment_method'] ?? '').toString()}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Amount: ₹${(booking['payment_amount'] ?? '').toString()}',
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor(status),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _paymentColor(
                                    paymentStatus,
                                  ).withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  paymentStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _paymentColor(paymentStatus),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (status == 'completed') ...[
                            const SizedBox(height: 12),
                            Text(
                              'Rating: ${(booking['rating'] ?? 'Not rated').toString()}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Feedback: ${(booking['feedback'] ?? 'No feedback').toString()}',
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
