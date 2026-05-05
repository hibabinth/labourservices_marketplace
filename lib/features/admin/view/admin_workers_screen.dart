import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadWorkers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    final filteredWorkers = vm.workers.where((worker) {
      final name = (worker['full_name'] ?? '').toString().toLowerCase();
      final phone = (worker['phone'] ?? '').toString().toLowerCase();
      final category = (worker['category'] ?? '').toString().toLowerCase();
      final location = (worker['location'] ?? '').toString().toLowerCase();
      final query = _searchController.text.trim().toLowerCase();

      return name.contains(query) ||
          phone.contains(query) ||
          category.contains(query) ||
          location.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Workers'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C274C),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search workers by name, phone, category...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE1E7F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE1E7F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E63F3),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null && vm.errorMessage!.trim().isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        vm.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                : filteredWorkers.isEmpty
                ? const Center(
                    child: Text(
                      'No workers found',
                      style: TextStyle(color: Color(0xFF7A8599)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      final worker = filteredWorkers[index];

                      final name = (worker['full_name'] ?? 'No Name')
                          .toString();
                      final phone = (worker['phone'] ?? '-').toString();
                      final category = (worker['category'] ?? '-').toString();
                      final location = (worker['location'] ?? '-').toString();
                      final availability = (worker['availability'] ?? '-')
                          .toString();
                      final experience = (worker['experience_years'] ?? '-')
                          .toString();
                      final isComplete =
                          (worker['is_profile_complete'] as bool?) ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFEAF1FF),
                              child: Text(
                                name.isNotEmpty
                                    ? name.substring(0, 1).toUpperCase()
                                    : 'W',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E63F3),
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
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1C274C),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Phone: $phone',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7A8599),
                                    ),
                                  ),
                                  Text(
                                    'Category: $category',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7A8599),
                                    ),
                                  ),
                                  Text(
                                    'Location: $location',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7A8599),
                                    ),
                                  ),
                                  Text(
                                    'Experience: $experience years',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7A8599),
                                    ),
                                  ),
                                  Text(
                                    'Availability: $availability',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7A8599),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _WorkerStatusChip(
                              label: isComplete ? 'Complete' : 'Incomplete',
                              isComplete: isComplete,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _WorkerStatusChip extends StatelessWidget {
  final String label;
  final bool isComplete;

  const _WorkerStatusChip({required this.label, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFE8F7EE) : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isComplete ? const Color(0xFF1E8E5A) : const Color(0xFFB26A00),
        ),
      ),
    );
  }
}
