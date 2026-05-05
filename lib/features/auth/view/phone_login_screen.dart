import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+8801XXXXXXXXX',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final phone = _phoneController.text.trim();
                      final ok = await vm.signInWithPhone(phone);

                      if (!context.mounted) return;

                      if (ok) {
                        Navigator.pushNamed(context, '/otp', arguments: phone);
                      }
                    },
              child: vm.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send OTP'),
            ),
            if (vm.errorMessage != null)
              Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
