import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('OTP sent to ${widget.phone}'),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final ok = await vm.verifyPhoneOtp(
                        phone: widget.phone,
                        otp: _otpController.text.trim(),
                      );

                      if (!context.mounted) return;

                      if (ok) {
                        final role = await vm.getRole();

                        if (!context.mounted) return;

                        if (role == null || role.isEmpty) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/role-selection',
                          );
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    },
              child: vm.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
            if (vm.errorMessage != null)
              Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
