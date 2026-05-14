import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  static const Color orange = Color(0xFFFF7A1A);
  static const Color bg = Color(0xFFFFF8F2);
  static const Color dark = Color(0xFF1C274C);
  static const Color muted = Color(0xFF7A8599);

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadWorkers(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<AdminViewModel>().loadWorkers(forceRefresh: true);
  }

  String _text(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    final filteredWorkers = vm.workers.where((worker) {
      final name = _text(worker['full_name']).toLowerCase();
      final phone = _text(worker['phone']).toLowerCase();
      final category = _text(worker['category']).toLowerCase();
      final location = _text(worker['location']).toLowerCase();
      final availability = _text(worker['availability']).toLowerCase();
      final query = _searchController.text.trim().toLowerCase();

      return name.contains(query) ||
          phone.contains(query) ||
          category.contains(query) ||
          location.contains(query) ||
          availability.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(total: filteredWorkers.length, onRefresh: _reload),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search workers by name, phone, category...',
                  prefixIcon: const Icon(Icons.search, color: orange),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFFFE1C7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFFFE1C7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: orange, width: 1.4),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reload,
                color: orange,
                child: vm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: orange),
                      )
                    : vm.errorMessage != null &&
                          vm.errorMessage!.trim().isNotEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 100),
                          Text(
                            vm.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      )
                    : filteredWorkers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 140),
                          Center(
                            child: Text(
                              'No workers found',
                              style: TextStyle(
                                color: muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: filteredWorkers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final worker = filteredWorkers[index];

                          final name = _text(
                            worker['full_name'],
                            fallback: 'No Name',
                          );
                          final phone = _text(worker['phone']);
                          final category = _text(worker['category']);
                          final location = _text(worker['location']);
                          final availability = _text(worker['availability']);
                          final experience = _text(
                            worker['experience_years'],
                            fallback: '0',
                          );
                          final skills = _text(worker['skills']);
                          final rate = _text(worker['rate'], fallback: '0');
                          final isComplete =
                              (worker['is_profile_complete'] as bool?) ?? false;

                          return _WorkerCard(
                            name: name,
                            phone: phone,
                            category: category,
                            location: location,
                            availability: availability,
                            experience: experience,
                            skills: skills,
                            rate: rate,
                            isComplete: isComplete,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;
  final Future<void> Function() onRefresh;

  const _Header({required this.total, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1A), Color(0xFFFFA24D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A1A).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.engineering, color: Color(0xFFFF7A1A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total service providers',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final String name;
  final String phone;
  final String category;
  final String location;
  final String availability;
  final String experience;
  final String skills;
  final String rate;
  final bool isComplete;

  const _WorkerCard({
    required this.name,
    required this.phone,
    required this.category,
    required this.location,
    required this.availability,
    required this.experience,
    required this.skills,
    required this.rate,
    required this.isComplete,
  });

  Color get availabilityColor {
    final value = availability.toLowerCase();

    if (value.contains('full') ||
        value.contains('available') ||
        value.contains('active')) {
      return Colors.green;
    }

    if (value.contains('part') ||
        value.contains('weekend') ||
        value.contains('on call') ||
        value.contains('busy')) {
      return Colors.orange;
    }

    return const Color(0xFFFF7A1A);
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'W';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE1C7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFFE8D6),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFFFF7A1A),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1C274C),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFF7A1A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                label: isComplete ? 'Complete' : 'Incomplete',
                color: isComplete ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoLine(icon: Icons.phone_outlined, text: phone),
          _InfoLine(icon: Icons.location_on_outlined, text: location),
          _InfoLine(
            icon: Icons.work_outline,
            text: '$experience years experience',
          ),
          _InfoLine(icon: Icons.schedule_outlined, text: availability),
          _InfoLine(icon: Icons.currency_rupee, text: 'Rate: ₹$rate'),
          _InfoLine(icon: Icons.build_outlined, text: 'Skills: $skills'),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatusChip(label: availability, color: availabilityColor),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF7A8599),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final displayText = text.trim().isEmpty ? '-' : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFFF7A1A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(
                color: Color(0xFF53627C),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = label.trim().isEmpty ? '-' : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
