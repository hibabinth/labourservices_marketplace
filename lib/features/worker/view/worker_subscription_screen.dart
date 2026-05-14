import 'package:flutter/material.dart';
import 'package:labour_service/features/user/view/payment_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class WorkerSubscriptionScreen extends StatefulWidget {
  const WorkerSubscriptionScreen({super.key});

  @override
  State<WorkerSubscriptionScreen> createState() =>
      _WorkerSubscriptionScreenState();
}

class _WorkerSubscriptionScreenState extends State<WorkerSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AuthViewModel>();
      await vm.loadWorkerSubscription();
      await vm.loadSubscriptionPlans();
    });
  }

  Future<void> _choosePlan(Map<String, dynamic> plan) async {
    final vm = context.read<AuthViewModel>();

    if (vm.hasActiveSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have an active plan')),
      );
      return;
    }

    final amount = (plan['price'] as num).toDouble();

    final paymentResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PaymentScreen(amount: amount, name: 'Labrix Worker', phone: ''),
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

    final success = await vm.activateWorkerSubscription(
      planId: plan['id'].toString(),
      amount: plan['price'] as num,
      durationDays: plan['duration_days'] as int,
      paymentId: paymentResult['payment_id']?.toString() ?? '',
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription activated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Failed to activate plan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final plans = vm.subscriptionPlans;
    final hasActiveSubscription = vm.hasActiveSubscription;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C274C),
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
          ? const Center(
              child: Text(
                'No subscription plans available',
                style: TextStyle(color: Color(0xFF7A8599)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: plans.length + (hasActiveSubscription ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (hasActiveSubscription && index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7EE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF1E8E5A),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You already have an active subscription.',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E8E5A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final planIndex = hasActiveSubscription ? index - 1 : index;
                final plan = plans[planIndex];

                final name = (plan['name'] ?? 'Plan').toString();
                final description = (plan['description'] ?? 'Subscription plan')
                    .toString();
                final price = plan['price'] ?? 0;
                final durationDays = plan['duration_days'] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1C274C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7A8599),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            '₹$price',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E63F3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ $durationDays days',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7A8599),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: hasActiveSubscription
                              ? null
                              : () => _choosePlan(plan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E63F3),
                            disabledBackgroundColor: const Color(0xFFB9C7E8),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            hasActiveSubscription
                                ? 'Already Active'
                                : 'Pay & Activate Plan',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
