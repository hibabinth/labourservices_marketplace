import 'package:flutter/material.dart';
import 'package:labour_service/features/user/view/worker_details_screen.dart';
import 'package:labour_service/features/user/viewmodel/service_viewmodel.dart';
import 'package:provider/provider.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedCategory;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) {
      selectedCategory = arg;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceViewModel>().searchWorkers(
        category: selectedCategory,
      );
    });
  }

  Future<void> _runSearch() async {
    await context.read<ServiceViewModel>().searchWorkers(
      searchText: _searchController.text,
      category: selectedCategory,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCategoryLabel(String raw) {
    return raw
        .split('_')
        .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }

  double _rating(Map<String, dynamic> worker) {
    return ((worker['average_rating'] as num?) ?? 0).toDouble();
  }

  int _reviewCount(Map<String, dynamic> worker) {
    return ((worker['total_reviews'] as num?) ?? 0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text(
          'Search Workers',
          style: TextStyle(color: Color(0xFF1C274C)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE3E8F2)),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _runSearch(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Color(0xFF7A8599)),
                    hintText: 'Search by worker, category, location...',
                    hintStyle: TextStyle(color: Color(0xFF7A8599)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (selectedCategory != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Category: ${_formatCategoryLabel(selectedCategory!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E63F3),
                          ),
                        ),
                      ),
                    ),
                  if (selectedCategory != null) const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _runSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E63F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _runSearch,
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.searchResults.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'No workers found.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF7A8599),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: vm.searchResults.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final worker = vm.searchResults[index];
                            final name =
                                (worker['full_name'] ?? 'Unknown Worker')
                                    .toString();
                            final category =
                                (worker['category'] ?? 'General Worker')
                                    .toString();
                            final location =
                                (worker['location'] ?? 'No location')
                                    .toString();
                            final rate = (worker['rate'] ?? 'N/A').toString();
                            final workerId = worker['id'].toString();
                            final avatarUrl = (worker['avatar_url'] ?? '')
                                .toString();
                            final rating = _rating(worker);
                            final reviews = _reviewCount(worker);

                            return _WorkerSearchCard(
                              name: name,
                              category: category,
                              location: location,
                              rate: rate,
                              avatarUrl: avatarUrl,
                              rating: rating,
                              reviews: reviews,
                              onView: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkerDetailsScreen(workerId: workerId),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerSearchCard extends StatelessWidget {
  final String name;
  final String category;
  final String location;
  final String rate;
  final String avatarUrl;
  final double rating;
  final int reviews;
  final VoidCallback onView;

  const _WorkerSearchCard({
    required this.name,
    required this.category,
    required this.location,
    required this.rate,
    required this.avatarUrl,
    required this.rating,
    required this.reviews,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: hasImage
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, color: Color(0xFF1E63F3)),
                    )
                  : const Icon(Icons.person, color: Color(0xFF1E63F3)),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C274C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • $location',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A8599),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C274C),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviews)',
                      style: const TextStyle(
                        color: Color(0xFF7A8599),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '₹$rate',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E63F3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onView,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E63F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
