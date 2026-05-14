import 'package:flutter/material.dart';
import 'package:labour_service/features/admin/view/admin_booking_screen.dart';
import 'package:labour_service/features/admin/view/admin_dashboard_screen.dart';
import 'package:labour_service/features/admin/view/admin_main_screen.dart';
import 'package:labour_service/features/admin/view/admin_users_screen.dart';
import 'package:labour_service/features/admin/view/admin_workers_screen.dart';
import 'package:labour_service/features/user/view/user_bookings_screen.dart';
import 'package:labour_service/features/user/view/user_main_screen.dart';
import 'package:labour_service/features/user/view/user_profile_screen.dart';
import 'package:labour_service/features/user/view/user_profile_setup_screen.dart';
import 'package:labour_service/features/user/view/user_search_screen.dart';
import 'package:labour_service/features/worker/view/worker_main_screen.dart';
import 'package:labour_service/features/worker/view/worker_category_screen.dart';
import 'package:labour_service/features/worker/view/worker_profile_setup_screen.dart';
import 'package:labour_service/features/worker/view/worker_subscription_screen.dart';

import '../features/auth/view/auth_gate_screen.dart';
import '../features/auth/view/forgot_password_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/otp_verification_screen.dart';
import '../features/auth/view/phone_login_screen.dart';
import '../features/auth/view/role_selection_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/auth/view/splash_screen.dart';

class LabrixApp extends StatelessWidget {
  const LabrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/auth-gate': (_) => const AuthGateScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/phone-login': (_) => const PhoneLoginScreen(),
        '/role-selection': (_) => const RoleSelectionScreen(),

        '/worker-category': (_) => const WorkerCategoryScreen(),
        '/worker-profile-setup': (_) => const WorkerProfileSetupScreen(),
        '/worker-home': (_) => const WorkerMainScreen(),
        '/worker-subscription': (_) => const WorkerSubscriptionScreen(),

        '/user-home': (_) => const UserMainScreen(),
        '/user-main': (_) => const UserMainScreen(),
        '/user-search': (_) => const UserSearchScreen(),
        '/user-bookings': (_) => const UserBookingsScreen(),
        '/user-profile': (_) => const UserProfileScreen(),
        '/user-profile-setup': (_) => const UserProfileSetupScreen(),

        '/admin-home': (_) => const AdminMainScreen(),
        '/admin-bookings': (_) => const AdminBookingsScreen(),
        '/admin-users': (_) => const AdminUsersScreen(),
        '/admin-workers': (_) => const AdminWorkersScreen(),

        '/super-admin-home': (_) =>
            const PlaceholderScreen(title: 'Super Admin Home'),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final phone = settings.arguments;

          if (phone is String) {
            return MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(phone: phone),
            );
          }

          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Invalid phone number passed to OTP screen'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
