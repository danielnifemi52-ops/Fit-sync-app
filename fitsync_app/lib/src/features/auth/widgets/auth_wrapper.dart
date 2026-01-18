import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../core/providers/user_data_provider.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // Trigger a fetch of user data when user logs in if not already loaded
          // We can use a FutureBuilder or useEffect to handle the async fetch if strictly needed,
          // but relying on the provider to eventually load is okay for now.
          // Ideally, UserDataProvider should listen to auth changes and load data automatically.

          final userData = ref.watch(userDataProvider);
          if (!userData.onboardingComplete) {
            return const OnboardingScreen();
          }
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
