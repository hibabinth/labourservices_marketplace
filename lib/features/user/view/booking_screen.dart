import 'package:flutter/material.dart';
import 'package:labour_service/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:labour_service/features/user/view/payment_screen.dart';
import 'package:labour_service/features/user/viewmodel/booking_viewmodel.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> worker;

  const BookingScreen({super.key, required this.worker});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _addressController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _urgency = 'Normal';
  double _paymentAmount = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().loadUserProfile();
    });

    final rateText = (widget.worker['rate'] ?? '0').toString();
    _paymentAmount = double.tryParse(rateText) ?? 0;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _addressController.text.trim().isEmpty ||
        _titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_paymentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid worker rate/payment amount')),
      );
      return;
    }

    final userVm = context.read<AuthViewModel>();
    final bookingVm = context.read<BookingViewModel>();
    final worker = widget.worker;
    final userData = userVm.userProfileData;

    final userName = (userData?['full_name'] ?? '').toString().trim();
    final userPhone = (userData?['phone'] ?? '').toString().trim();

    if (userName.isEmpty || userPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your profile before booking'),
        ),
      );
      return;
    }

    final paymentResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          amount: _paymentAmount,
          name: userName,
          phone: userPhone,
        ),
      ),
    );

    if (!mounted) return;

    if (paymentResult == null || paymentResult['status'] != 'paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paymentResult?['message'] ?? 'Payment failed or cancelled',
          ),
        ),
      );
      return;
    }

    final paymentId = paymentResult['payment_id']?.toString() ?? '';

    final ok = await bookingVm.createBooking(
      workerId: worker['id'].toString(),
      workerName: (worker['full_name'] ?? 'Unknown Worker').toString(),
      workerPhone: (worker['phone'] ?? '').toString(),
      workerCategory: (worker['category'] ?? '').toString(),
      userName: userName,
      userPhone: userPhone,
      bookingDate: _selectedDate!.toIso8601String().split('T').first,
      bookingTime: _selectedTime!.format(context),
      bookingAddress: _addressController.text.trim(),
      serviceTitle: _titleController.text.trim(),
      serviceDescription: _descriptionController.text.trim(),
      bookingNote: _noteController.text.trim(),
      urgency: _urgency,
      paymentMethod: 'Razorpay',
      paymentAmount: _paymentAmount,
      paymentId: paymentId,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/user-bookings',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingVm.errorMessage ?? 'Booking failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingVm = context.watch<BookingViewModel>();
    final worker = widget.worker;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text(
          'Professional Booking',
          style: TextStyle(color: Color(0xFF1C274C)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (worker['full_name'] ?? 'Unknown Worker').toString(),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C274C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (worker['category'] ?? '').toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A8599),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment: ₹${_paymentAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E63F3),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Service Needed',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Service Description',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _pickDate,
                  child: _PickerTile(
                    icon: Icons.date_range,
                    text: _selectedDate == null
                        ? 'Select Date'
                        : _selectedDate!.toIso8601String().split('T').first,
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: _pickTime,
                  child: _PickerTile(
                    icon: Icons.access_time,
                    text: _selectedTime == null
                        ? 'Select Time'
                        : _selectedTime!.format(context),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _urgency,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (v) => setState(() => _urgency = v!),
                  decoration: InputDecoration(
                    labelText: 'Urgency',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Color(0xFF1E63F3)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Full online payment is required before booking confirmation.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C274C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: bookingVm.isLoading ? null : _submit,
                    child: bookingVm.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Pay & Confirm Booking'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PickerTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [Icon(icon), const SizedBox(width: 10), Text(text)]),
    );
  }
}
