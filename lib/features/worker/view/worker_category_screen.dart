import 'package:flutter/material.dart';
import 'package:labour_service/core/constants/labour_categories.dart';
import 'package:labour_service/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class WorkerCategoryScreen extends StatefulWidget {
  const WorkerCategoryScreen({super.key});

  @override
  State<WorkerCategoryScreen> createState() => _WorkerCategoryScreenState();
}

class _WorkerCategoryScreenState extends State<WorkerCategoryScreen> {
  String? _selectedCategory;

  Future<void> _continue(AuthViewModel vm) async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final ok = await vm.saveWorkerCategory(_selectedCategory!);

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, '/worker-profile-setup');
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text(
          'Select Service Category',
          style: TextStyle(color: Color(0xFF1C274C)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Your Labour Service',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C274C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the service category you provide',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  itemCount: LabourCategories.all.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final item = LabourCategories.all[index];
                    final isSelected = _selectedCategory == item.key;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = item.key;
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEAF1FF)
                              : const Color(0xFFF9FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1E63F3)
                                : const Color(0xFFE1E7F0),
                            width: isSelected ? 1.4 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 32,
                              color: const Color(0xFF1E63F3),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C274C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _continue(vm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E63F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
