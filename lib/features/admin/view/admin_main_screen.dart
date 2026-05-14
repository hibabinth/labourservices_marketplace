import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_booking_screen.dart';
import 'admin_users_screen.dart';
import 'admin_workers_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminBookingsScreen(),
    AdminUsersScreen(),
    AdminWorkersScreen(),
    _AdminPlansPlaceholderScreen(),
  ];

  Future<bool> _handleBack() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          height: 74,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFE8D6),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              selectedIcon: Icon(Icons.people_alt),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.engineering_outlined),
              selectedIcon: Icon(Icons.engineering),
              label: 'Workers',
            ),
            NavigationDestination(
              icon: Icon(Icons.workspace_premium_outlined),
              selectedIcon: Icon(Icons.workspace_premium),
              label: 'Plans',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPlansPlaceholderScreen extends StatelessWidget {
  const _AdminPlansPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8F2),
      body: Center(
        child: Text(
          'Plans screen coming next',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C274C),
          ),
        ),
      ),
    );
  }
}
