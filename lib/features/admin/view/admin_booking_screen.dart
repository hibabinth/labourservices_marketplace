import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('All Bookings')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.recentBookings.length,
              itemBuilder: (context, index) {
                final b = vm.recentBookings[index];

                return ListTile(
                  title: Text(
                    (b['service_title'] ?? 'Service Booking').toString(),
                  ),
                  subtitle: Text(
                    '${b['user_name'] ?? 'User'} → ${b['worker_name'] ?? 'Worker'}',
                  ),
                  trailing: Text((b['status'] ?? 'pending').toString()),
                );
              },
            ),
    );
  }
}
