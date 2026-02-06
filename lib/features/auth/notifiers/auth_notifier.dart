import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/auth/data/auth_repository_impl.dart';
import 'package:mens/features/auth/domain/user_profile.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>(AuthNotifier.new);

class AuthNotifier extends Notifier<AsyncValue<UserProfile?>> {
  @override
  AsyncValue<UserProfile?> build() {
    // Call the async function to start the check, but DO NOT return its result.
    _checkInitialAuthStatus();

    // Return a valid initial state synchronously.
    // Starting with loading is usually best while checking auth.
    return const AsyncValue.loading();
  }

  Future<void> _checkInitialAuthStatus() async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(
      secureStorageProvider,
    ); // Assuming you have this provider
    final token = await storage.read(key: 'jwt_token');

    // Small delay helps prevent race conditions during widget build
    await Future.delayed(Duration.zero);

    try {
      if (token != null) {
        final userData = await repo
            .getUserData(); // Will use cache if available
        // Update state if successful
        state = AsyncValue.data(userData);
      } else {
        // No token, ensure state is logged out
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      // If getUserData fails (e.g., token expired/invalid), log out
      await repo.logout(); // Clear token and cache
      state = const AsyncValue.data(null); // Set state to logged out
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final repo = ref.read(authRepositoryProvider);
    try {
      final userData = await repo.login(email, password);
      state = AsyncValue.data(userData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  void loginAsGuest() {
    state = const AsyncValue.loading();
    try {
      final guestProfile = UserProfile(
        userId: 0, // 0 identifies a guest
        email: 'guest@mens.com',
        firstName: 'Guest',
        lastName: 'User',
        fullName: 'Guest User',
        role: 'customer', // Use standard 'customer' role
        emailConfirmed: true,
        createdAt: DateTime.now(),
      );
      state = AsyncValue.data(guestProfile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void setLoggedOut() {
    state = const AsyncValue.data(null);
  }

  Future<void> refreshProfile() async {
    final repo = ref.read(authRepositoryProvider);
    try {
      final userData = await repo.getUserData(forceRefresh: true);
      state = AsyncValue.data(userData);
    } catch (e) {
      // Don't necessarily log out, just keep old state or show error
    }
  }

  // Getter to easily check login status
  bool get isLoggedIn => state.hasValue && state.value != null;
}
