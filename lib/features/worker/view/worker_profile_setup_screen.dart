import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:labour_service/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class WorkerProfileSetupScreen extends StatefulWidget {
  const WorkerProfileSetupScreen({super.key});

  @override
  State<WorkerProfileSetupScreen> createState() =>
      _WorkerProfileSetupScreenState();
}

class _WorkerProfileSetupScreenState extends State<WorkerProfileSetupScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _rateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  String? _availability;
  bool _isPrefilled = false;

  final List<String> _availabilityOptions = [
    'Full Time',
    'Part Time',
    'Weekends Only',
    'On Call',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AuthViewModel>();
      await vm.loadWorkerProfile();
      await vm.loadProfileImageUrl();

      final data = vm.workerProfileData;
      if (data == null || _isPrefilled) return;

      _fullNameController.text = data['full_name']?.toString() ?? '';
      _phoneController.text = data['phone']?.toString() ?? '';
      _locationController.text = data['location']?.toString() ?? '';
      _experienceController.text = data['experience_years']?.toString() ?? '';
      _bioController.text = data['bio']?.toString() ?? '';
      _skillsController.text = data['skills']?.toString() ?? '';
      _rateController.text = data['rate']?.toString() ?? '';

      if (mounted) {
        setState(() {
          _availability = data['availability']?.toString();
          _isPrefilled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Update Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C274C),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _PickerOptionCard(
                        icon: Icons.photo_camera_outlined,
                        title: 'Camera',
                        onTap: () async {
                          Navigator.pop(context);
                          final image = await _picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 75,
                          );

                          if (image != null) {
                            final file = File(image.path);

                            setState(() {
                              _selectedImage = file;
                            });

                            final ok = await context
                                .read<AuthViewModel>()
                                .uploadProfileImage(file);

                            if (!mounted) return;

                            if (ok) {
                              await context
                                  .read<AuthViewModel>()
                                  .loadProfileImageUrl();
                              await context
                                  .read<AuthViewModel>()
                                  .loadWorkerProfile();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context
                                            .read<AuthViewModel>()
                                            .errorMessage ??
                                        'Failed to upload image',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerOptionCard(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        onTap: () async {
                          Navigator.pop(context);
                          final image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 75,
                          );

                          if (image != null) {
                            final file = File(image.path);

                            setState(() {
                              _selectedImage = file;
                            });

                            final ok = await context
                                .read<AuthViewModel>()
                                .uploadProfileImage(file);

                            if (!mounted) return;

                            if (ok) {
                              await context
                                  .read<AuthViewModel>()
                                  .loadProfileImageUrl();
                              await context
                                  .read<AuthViewModel>()
                                  .loadWorkerProfile();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context
                                            .read<AuthViewModel>()
                                            .errorMessage ??
                                        'Failed to upload image',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save(AuthViewModel vm) async {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final bio = _bioController.text.trim();
    final skills = _skillsController.text.trim();
    final rate = _rateController.text.trim();
    final experienceYears =
        int.tryParse(_experienceController.text.trim()) ?? 0;

    if (fullName.isEmpty ||
        phone.isEmpty ||
        location.isEmpty ||
        bio.isEmpty ||
        skills.isEmpty ||
        rate.isEmpty ||
        _availability == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final ok = await vm.saveWorkerProfile(
      fullName: fullName,
      phone: phone,
      location: location,
      bio: bio,
      experienceYears: experienceYears,
      skills: skills,
      rate: rate,
      availability: _availability!,
    );

    if (!mounted) return;

    if (ok) {
      await vm.loadWorkerProfile();
      await vm.loadProfileImageUrl();
      Navigator.pop(context, true);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    Widget avatarChild;
    if (_selectedImage != null) {
      avatarChild = ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      );
    } else if (vm.profileImageUrl != null && vm.profileImageUrl!.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.network(
          vm.profileImageUrl!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, size: 48, color: Color(0xFF1E63F3)),
        ),
      );
    } else {
      avatarChild = const Icon(
        Icons.person,
        size: 48,
        color: Color(0xFF1E63F3),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        title: const Text(
          'Edit Worker Profile',
          style: TextStyle(
            color: Color(0xFF1C274C),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C274C)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
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
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE1E7F0),
                                width: 3,
                              ),
                            ),
                            child: avatarChild,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: vm.isLoading ? null : _pickImage,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C274C),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: vm.isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    const _SectionTitle(
                      title: 'Personal Information',
                      subtitle: 'Update your basic details',
                    ),
                    const SizedBox(height: 18),

                    _ProfileField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle(
                      title: 'Service Information',
                      subtitle: 'Update your work profile',
                    ),
                    const SizedBox(height: 18),

                    _ProfileField(
                      controller: _experienceController,
                      label: 'Experience (Years)',
                      icon: Icons.work_outline,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      controller: _skillsController,
                      label: 'Skills / Specialties',
                      icon: Icons.build_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      controller: _bioController,
                      label: 'Professional Bio',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle(
                      title: 'Work Details',
                      subtitle: 'Help users find and book you',
                    ),
                    const SizedBox(height: 18),

                    _ProfileField(
                      controller: _locationController,
                      label: 'Location',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      controller: _rateController,
                      label: 'Starting Price / Daily Rate',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _availability,
                      items: _availabilityOptions
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _availability = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Availability',
                        prefixIcon: const Icon(
                          Icons.schedule_outlined,
                          color: Color(0xFF7A8599),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E7F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E7F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E63F3),
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),

                    if (vm.errorMessage != null &&
                        vm.errorMessage!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : () => _save(vm),
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
                                'Save Changes',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C274C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF7A8599)),
        filled: true,
        fillColor: const Color(0xFFF9FAFC),
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
          borderSide: const BorderSide(color: Color(0xFF1E63F3), width: 1.3),
        ),
      ),
    );
  }
}

class _PickerOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PickerOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1E7F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF1E63F3)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C274C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
