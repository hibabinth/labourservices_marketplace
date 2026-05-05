import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    try {
      final vm = context.read<AuthViewModel>();

      if (!vm.isLoggedIn) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final role = await vm.getRole();

      if (!mounted) return;

      if (role == null || role.isEmpty) {
        Navigator.pushReplacementNamed(context, '/role-selection');
        return;
      }

      switch (role) {
        case 'user':
          Navigator.pushReplacementNamed(context, '/user-home');
          break;

        case 'worker':
          final category = await vm.getWorkerCategory();

          if (!mounted) return;

          if (category == null || category.isEmpty) {
            Navigator.pushReplacementNamed(context, '/worker-category');
            return;
          }

          final isComplete = await vm.isWorkerProfileComplete();

          if (!mounted) return;

          if (isComplete) {
            Navigator.pushReplacementNamed(context, '/worker-home');
          } else {
            Navigator.pushReplacementNamed(context, '/worker-profile-setup');
          }
          break;

        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin-home');
          break;

        case 'super_admin':
          Navigator.pushReplacementNamed(context, '/super-admin-home');
          break;

        default:
          Navigator.pushReplacementNamed(context, '/role-selection');
      }
    } catch (e, st) {
      debugPrint('AuthGate error: $e');
      debugPrint('$st');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
