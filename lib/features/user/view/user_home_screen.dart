import 'package:flutter/material.dart';
import 'package:labour_service/core/constants/labour_categories.dart';
import 'package:labour_service/features/chat/repository/chat_repository.dart';
import 'package:labour_service/features/chat/view/chat_room_screen.dart';
import 'package:labour_service/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:labour_service/features/user/view/worker_details_screen.dart';
import 'package:labour_service/features/user/viewmodel/service_viewmodel.dart';
import 'package:provider/provider.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAllCategories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceViewModel>().loadTopWorkers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openWorkerChat({
    required String workerId,
    required String workerName,
    required String workerCategory,
    required String workerPhone,
  }) async {
    try {
      final chatRepository = context.read<ChatRepository>();
      final currentUserId = chatRepository.currentUserId;

      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      final chatId = await chatRepository.getOrCreateChat(
        userId: currentUserId,
        workerId: workerId,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            title: workerName,
            subtitle: workerCategory.isEmpty
                ? workerPhone
                : workerPhone.isEmpty
                ? workerCategory
                : '$workerCategory • $workerPhone',
          ),
        ),
      );

      if (!mounted) return;
      await context.read<ChatViewModel>().loadUserChats();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
    }
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
    final allCategories = LabourCategories.all;
    final categoriesToShow = _showAllCategories
        ? allCategories
        : allCategories.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: vm.loadTopWorkers,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HomeHeader(),
                const SizedBox(height: 20),
                const _HeroBanner(),
                const SizedBox(height: 18),
                _SearchCard(
                  controller: _searchController,
                  onTap: () {
                    Navigator.pushNamed(context, '/user-search');
                  },
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle(title: 'Categories'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllCategories = !_showAllCategories;
                        });
                      },
                      child: Text(
                        _showAllCategories ? 'See Less' : 'See More',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E63F3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  itemCount: categoriesToShow.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: _showAllCategories ? 0.95 : 1.02,
                  ),
                  itemBuilder: (context, index) {
                    final item = categoriesToShow[index];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/user-search',
                          arguments: item.key,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
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
                          border: Border.all(color: const Color(0xFFE5EBF3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF1FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                item.icon,
                                color: const Color(0xFF1E63F3),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C274C),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                const _SectionTitle(title: 'Top Workers'),
                const SizedBox(height: 14),
                if (vm.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (vm.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                else if (vm.topWorkers.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'No workers found.',
                      style: TextStyle(color: Color(0xFF7A8599)),
                    ),
                  )
                else
                  ListView.separated(
                    itemCount: vm.topWorkers.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final worker = vm.topWorkers[index];
                      final workerId = worker['id'].toString();
                      final name = (worker['full_name'] ?? 'Unknown Worker')
                          .toString();
                      final location =
                          (worker['location'] ?? 'Location not added')
                              .toString();
                      final rate = (worker['rate'] ?? 'N/A').toString();
                      final category = (worker['category'] ?? 'General Worker')
                          .toString();
                      final phone = (worker['phone'] ?? '').toString();
                      final availability =
                          (worker['availability'] ?? 'Unavailable').toString();
                      final avatarUrl = (worker['avatar_url'] ?? '').toString();
                      final rating = _rating(worker);
                      final reviews = _reviewCount(worker);

                      return _TopWorkerCard(
                        name: name,
                        category: category,
                        location: location,
                        rate: rate,
                        availability: availability,
                        avatarUrl: avatarUrl,
                        rating: rating,
                        reviews: reviews,
                        onChat: () => _openWorkerChat(
                          workerId: workerId,
                          workerName: name,
                          workerCategory: category,
                          workerPhone: phone,
                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopWorkerCard extends StatelessWidget {
  final String name;
  final String category;
  final String location;
  final String rate;
  final String availability;
  final String avatarUrl;
  final double rating;
  final int reviews;
  final VoidCallback onChat;
  final VoidCallback onView;

  const _TopWorkerCard({
    required this.name,
    required this.category,
    required this.location,
    required this.rate,
    required this.availability,
    required this.avatarUrl,
    required this.rating,
    required this.reviews,
    required this.onChat,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = availability.toLowerCase() == 'available';
    final hasImage = avatarUrl.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAF1FF), Color(0xFFDCE8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: hasImage
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFF1E63F3),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 30,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C274C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E63F3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A8599),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.10)
                      : Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  availability,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isAvailable ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C274C),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($reviews)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A8599)),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.currency_rupee_rounded,
                size: 18,
                color: Color(0xFF1E63F3),
              ),
              Text(
                rate,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E63F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onChat,
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Chat',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E63F3),
                      side: const BorderSide(color: Color(0xFF1E63F3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E63F3),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
              ),
              SizedBox(height: 4),
              Text(
                'Find trusted professionals',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C274C),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF1C274C),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E63F3), Color(0xFF4D8DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E63F3).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book trusted\nworkers faster',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Search by category, compare professionals, and book the right worker for your service needs.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;

  const _SearchCard({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF7A8599)),
          hintText: 'Search services, workers, location...',
          hintStyle: TextStyle(color: Color(0xFF7A8599)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1C274C),
      ),
    );
  }
}
