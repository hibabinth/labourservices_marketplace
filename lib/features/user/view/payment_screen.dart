import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String name;
  final String phone;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.phone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _paymentStarted = false;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCheckout();
    });
  }

  void _openCheckout() {
    setState(() => _paymentStarted = true);

    final key = dotenv.env['RAZORPAY_KEY_ID'];

    if (key == null || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Razorpay key missing in .env')),
      );
      Navigator.pop(context, null);
      return;
    }

    final amountInPaise = (widget.amount * 100).round();

    final options = {
      'key': key,
      'amount': amountInPaise,
      'name': 'Labrix',
      'description': 'Worker Booking Payment',
      'prefill': {'contact': widget.phone, 'name': widget.name},
      'theme': {'color': '#1E63F3'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Navigator.pop(context, null);
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    Navigator.pop(context, {
      'status': 'paid',
      'payment_id': response.paymentId,
    });
  }

  void _handleError(PaymentFailureResponse response) {
    Navigator.pop(context, {
      'status': 'failed',
      'message': response.message ?? 'Payment failed',
    });
  }

  void _handleWallet(ExternalWalletResponse response) {}

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: _paymentStarted
            ? const Text('Complete payment in Razorpay...')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
