import 'package:flutter/material.dart';

class WorkerSubscriptionScreen extends StatelessWidget {
  const WorkerSubscriptionScreen({super.key});

  final List<Map<String, dynamic>> plans = const [
    {
      'name': 'Basic Plan',
      'price': 199,
      'duration': '30 days',
      'description': 'Best for new workers',
    },
    {
      'name': 'Standard Plan',
      'price': 499,
      'duration': '90 days',
      'description': 'Most popular plan',
    },
    {
      'name': 'Premium Plan',
      'price': 999,
      'duration': '180 days',
      'description': 'Best value for professionals',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C274C),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final plan = plans[index];

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
                  plan['name'].toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C274C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan['description'].toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A8599),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      '₹${plan['price']}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E63F3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ ${plan['duration']}',
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${plan['name']} selected')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E63F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Choose Plan',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
