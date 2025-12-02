import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/features/user/conversations/presentation/conversations_view.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/auth/presentation/register/register_screen.dart';
import 'package:mens/features/auth/presentation/signin/signin_screen.dart';
import 'package:mens/features/auth/presentation/register/roles_selection.dart';
import 'package:mens/features/auth/presentation/register/customer_register.dart';
// seller home screen import removed (unused in router)
import 'package:mens/features/seller/Orders/presentation/orders_screen.dart';
import 'package:mens/features/seller/Products/presentation/add_product_screen.dart';
import 'package:mens/features/seller/Products/presentation/edit_products_screen.dart';
import 'package:mens/features/seller/Products/presentation/products_screen.dart';
import 'package:mens/features/seller/Products/presentation/paginated_products_screen.dart';
import 'package:mens/features/seller/Statistics/presentation/stat_screen.dart';
import 'package:mens/features/seller/contact_us/presentation/contact_us_screen.dart';
import 'package:mens/features/user/user_home/presentation/user_home_screen.dart';
import 'package:mens/features/user/profile/presentation/edit_profile_screen.dart';
import 'package:mens/features/user/profile/presentation/help_support_screen.dart';
import 'package:mens/features/user/profile/presentation/notification_screen.dart';
import 'package:mens/features/user/profile/presentation/profile_screen.dart';
import 'package:mens/features/user/profile/presentation/shop_info_screen.dart';

class AppRoutes {
  static const signIn = '/signIn';
  static const settings = '/settings';
  static const register = '/register';
  static const roleSelection = '/register/role-selection';
  static const registerCustomer = '/register/customer';
  static const home = '/home';
  static const userHome = '/user/home';
  static const userProducts = '/user/products';
  static const userBrands = '/user/brands';
  static const adminConversations = '/admin/conversations';
  static const products = '/products';
  static const paginatedProducts = '/paginated-products';
  static const addProduct = '/addProduct';
  static const orders = '/orders';
  static const profile = '/profile';
  static const statistics = '/statistics';
  static const editProfile = '/profile/edit';
  static const helpSupport = '/help';
  static const shopInformation = '/profile/shop-information';
  static const notifications = '/profile/notifications';
  static const editProduct = '/products/:id/edit';
  static const productDetails = '/product-details';
  static const contactUs = '/contact-us';
  static const customersHome = 'customers-home';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    refreshListenable: GoRouterRefreshNotifier(ref),
    initialLocation: AppRoutes.signIn,
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerCustomer,
        builder: (context, state) => const RegisterCustomerScreen(),
      ),
      GoRoute(
        path: AppRoutes.userHome,
        redirect: (context, state) => AppRoutes.userProducts,
      ),
      GoRoute(
        path: AppRoutes.userProducts,
        builder: (context, state) => const UserHomeScreen(initialIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.userBrands,
        builder: (context, state) => const UserHomeScreen(initialIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.adminConversations,
        builder: (context, state) => const ConversationsView(),
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) => const PaginatedProductsScreen(),
      ),
      GoRoute(
        path: '/products-original',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.paginatedProducts,
        builder: (context, state) => const PaginatedProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addProduct,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.statistics,
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.shopInformation,
        builder: (context, state) => const ShopInformationScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/products/:id/edit', // Match the path structure
        builder: (context, state) {
          final productId = int.tryParse(state.pathParameters['id'] ?? '');
          if (productId == null) {
            // Handle error: redirect or show not found page
            return Scaffold(
              body: Center(
                child: Text(AppLocalizations.of(context)!.invalidProductId),
              ),
            );
          }
          return EditProductScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.contactUs,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: AppRoutes.userHome,
        builder: (context, state) => const UserHomeScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.watch(authNotifierProvider); // Watch the full state
      final bool isLoggedIn = authNotifier.isLoggedIn; // Use the getter

      final location = state.matchedLocation;
      // Consider any path under /register as an auth route (role selection, register, customer)
      final isGoingToAuthRoute =
          location == AppRoutes.signIn || location.startsWith('/register');

      // --- NEWER, STRICTER REDIRECTION RULES ---

      // 1. If the state is loading, ALWAYS stay on the current screen.
      //    This prevents redirects during login attempts or initial checks.
      if (authState is AsyncLoading) {
        return null; // Do nothing, wait for loading to finish
      }

      // 2. Handle errors explicitly: If there's an error state AND the user isn't logged in,
      //    ensure they are on or going to an auth route. If not, send to signIn.
      if (authState is AsyncError && !isLoggedIn && !isGoingToAuthRoute) {
        return AppRoutes.signIn;
      }

      // 3. If NOT logged in (and not loading/error handled above)
      //    AND trying to access a protected route -> redirect to signIn.
      if (!isLoggedIn && !isGoingToAuthRoute) {
        return AppRoutes.signIn;
      }

      // 4. If IS logged in, check role-based routing
      if (isLoggedIn) {
        final userRole = authState.asData?.value?.role;

        // --- ROLE-BASED REDIRECT LOGIC ---
        if (userRole == 'Admin') {
          // If admin is logged in and tries to go to a seller route, redirect to admin products
          if (location == AppRoutes.home || isGoingToAuthRoute) {
            return AppRoutes.userHome;
          }
        } else if (userRole == 'StoreOwner') {
          // If seller is logged in and tries to go to an admin route, redirect to seller home
          if (location.startsWith('/admin') || isGoingToAuthRoute) {
            return AppRoutes.home;
          }
        }

        // If logged in and trying to access auth routes, redirect based on role
        if (isGoingToAuthRoute) {
          return userRole == 'Admin' ? AppRoutes.userProducts : AppRoutes.home;
        }
      }

      // 5. Otherwise (logged in on protected route, logged out on auth route), allow.
      return null;
    },
  );
});

// Helper class to listen to Notifier changes for GoRouter refresh
class GoRouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;
  GoRouterRefreshNotifier(this._ref) {
    // Listen to the provider's state changes
    _ref.listen(authNotifierProvider, (_, __) {
      // Notify GoRouter that something changed
      notifyListeners();
    });
  }
}
