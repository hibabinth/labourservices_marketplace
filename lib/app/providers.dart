import 'package:flutter/material.dart';
import 'package:labour_service/features/chat/repository/chat_repository.dart';
import 'package:labour_service/features/chat/viewmodel/chat_room_viewmodel.dart';
import 'package:labour_service/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:labour_service/features/user/repository/booking_repository.dart';
import 'package:labour_service/features/user/viewmodel/booking_viewmodel.dart';
import 'package:labour_service/features/worker/repository/worker_booking_repository.dart';
import 'package:labour_service/features/worker/viewmodel/worker_booking_viewmodel.dart';
import 'package:labour_service/features/worker/viewmodel/worker_home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../features/admin/repository/admin_repository.dart';
import '../features/admin/viewmodel/admin_viewmodel.dart';
import '../features/worker/repository/worker_profile_repository.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import '../features/user/repository/service_repository.dart';
import '../features/user/viewmodel/service_viewmodel.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return MultiProvider(
      providers: [
        Provider<SupabaseClient>.value(value: client),
        Provider<SupabaseService>(create: (_) => SupabaseService(client)),

        Provider<AuthRepository>(
          create: (context) => AuthRepository(context.read<SupabaseService>()),
        ),
        Provider<ProfileRepository>(
          create: (context) =>
              ProfileRepository(context.read<SupabaseService>()),
        ),
        Provider<WorkerProfileRepository>(
          create: (context) =>
              WorkerProfileRepository(context.read<SupabaseService>()),
        ),
        Provider<ServiceRepository>(
          create: (context) =>
              ServiceRepository(context.read<SupabaseService>()),
        ),
        Provider<ChatRepository>(
          create: (context) => ChatRepository(context.read<SupabaseService>()),
        ),
        Provider<BookingRepository>(
          create: (context) =>
              BookingRepository(context.read<SupabaseService>()),
        ),
        Provider<WorkerBookingRepository>(
          create: (context) =>
              WorkerBookingRepository(context.read<SupabaseService>()),
        ),
        Provider<AdminRepository>(
          create: (context) => AdminRepository(context.read<SupabaseService>()),
        ),

        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository: context.read<AuthRepository>(),
            profileRepository: context.read<ProfileRepository>(),
            workerProfileRepository: context.read<WorkerProfileRepository>(),
          ),
        ),
        ChangeNotifierProvider<ServiceViewModel>(
          create: (context) =>
              ServiceViewModel(repository: context.read<ServiceRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BookingViewModel(repository: context.read<BookingRepository>()),
        ),
        ChangeNotifierProvider<WorkerBookingViewModel>(
          create: (context) => WorkerBookingViewModel(
            repository: context.read<WorkerBookingRepository>(),
            chatRepository: context.read<ChatRepository>(),
          ),
        ),
        ChangeNotifierProvider<WorkerHomeViewModel>(
          create: (context) => WorkerHomeViewModel(
            bookingRepository: context.read<WorkerBookingRepository>(),
            profileRepository: context.read<WorkerProfileRepository>(),
            chatRepository: context.read<ChatRepository>(),
          ),
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) =>
              ChatViewModel(repository: context.read<ChatRepository>()),
        ),
        ChangeNotifierProvider<ChatRoomViewModel>(
          create: (context) =>
              ChatRoomViewModel(repository: context.read<ChatRepository>()),
        ),
        ChangeNotifierProvider<AdminViewModel>(
          create: (context) =>
              AdminViewModel(repository: context.read<AdminRepository>()),
        ),
      ],
      child: child,
    );
  }
}
