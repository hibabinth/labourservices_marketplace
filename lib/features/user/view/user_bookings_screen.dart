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

  Future<void> _showReviewDialog(Map<String, dynamic> booking) async {
    double rating = 5;
    final feedbackController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Rate Worker'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (booking['worker_name'] ?? 'Worker').toString(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              rating = starValue.toDouble();
                            });
                          },
                          icon: Icon(
                            starValue <= rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      feedbackController.dispose();
      return;
    }

    final bookingId = booking['id']?.toString();
    if (bookingId == null || bookingId.isEmpty) {
      feedbackController.dispose();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid booking id')));
      return;
    }

    final vm = context.read<BookingViewModel>();

    final success = await vm.submitFeedback(
      bookingId: bookingId,
      rating: rating,
      feedback: feedbackController.text.trim(),
    );

    feedbackController.dispose();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Review submitted successfully'
              : vm.errorMessage ?? 'Failed to submit review',
        ),
      ),
    );
  }

  bool _hasReview(Map<String, dynamic> booking) {
    final rating = booking['rating'];
    final feedback = booking['feedback'];

    final hasRating = rating != null && rating.toString().trim().isNotEmpty;
    final hasFeedback =
        feedback != null && feedback.toString().trim().isNotEmpty;

    return hasRating || hasFeedback;
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

                    final hasReview = _hasReview(booking);
                    final canReview = status == 'completed' && !hasReview;

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
                              _Chip(
                                label: _statusLabel(status),
                                color: _statusColor(status),
                              ),
                              _Chip(
                                label: paymentStatus.toUpperCase(),
                                color: _paymentColor(paymentStatus),
                              ),
                            ],
                          ),
                          if (status == 'completed') ...[
                            const SizedBox(height: 14),
                            if (hasReview)
                              _ReviewPreview(
                                rating: booking['rating'],
                                feedback: booking['feedback'],
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showReviewDialog(booking),
                                  icon: const Icon(Icons.star_outline),
                                  label: const Text('Write Review'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E63F3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
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

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _ReviewPreview extends StatelessWidget {
  final dynamic rating;
  final dynamic feedback;

  const _ReviewPreview({required this.rating, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final ratingText = rating?.toString() ?? '0';
    final feedbackText = feedback?.toString().trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E8F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                ratingText,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C274C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            feedbackText.isEmpty ? 'No feedback' : feedbackText,
            style: const TextStyle(color: Color(0xFF53627C)),
          ),
        ],
      ),
    );
  }
}
