import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/features/seller/profile/presentation/seller_profile_screen.dart'
    show SellerProfileScreen;
import 'package:mens/features/user/conversations/presentation/conversations_view.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/auth/presentation/register/register_screen.dart';
import 'package:mens/features/auth/presentation/signin/signin_screen.dart';
import 'package:mens/features/auth/presentation/register/roles_selection.dart';
import 'package:mens/features/auth/presentation/register/customer_register.dart';
import 'package:mens/features/auth/presentation/otp/otp_verification_screen.dart';
import 'package:mens/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:mens/features/auth/presentation/forgot_password/reset_password_screen.dart';
import 'package:mens/features/seller/Orders/presentation/orders_screen.dart';
import 'package:mens/features/seller/Orders/presentation/order_details_screen.dart';
import 'package:mens/features/seller/Products/presentation/add_product_screen.dart';
import 'package:mens/features/seller/Products/presentation/edit_products_screen.dart';
import 'package:mens/features/seller/Products/presentation/products_screen.dart';
import 'package:mens/features/seller/Products/presentation/paginated_products_screen.dart';
import 'package:mens/features/seller/Statistics/presentation/stat_screen.dart';
import 'package:mens/features/seller/contact_us/presentation/contact_us_screen.dart';
import 'package:mens/features/user/user_home/presentation/user_home_screen.dart';
import 'package:mens/features/seller/Home/presentation/home_screen.dart';
import 'package:mens/features/user/profile/presentation/edit_profile_screen.dart';
import 'package:mens/features/user/profile/presentation/help_support_screen.dart';
import 'package:mens/features/user/profile/presentation/notification_screen.dart';
import 'package:mens/features/user/profile/presentation/user_profile_screen.dart';
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
  static const userProfile = '/user/profile';
  static const sellerProfile = '/seller/profile';
  static const statistics = '/statistics';
  static const editProfile = '/profile/edit';
  static const helpSupport = '/help';
  static const shopInformation = '/profile/shop-information';
  static const notifications = '/profile/notifications';
  static const editProduct = '/products/:id/edit';
  static const productDetails = '/product-details';
  static const contactUs = '/contact-us';
  static const customersHome = '/customers-home';
  static const orderDetails = '/orders/:id';
  static const confirmEmail = '/auth/confirm-email';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    refreshListenable: GoRouterRefreshNotifier(ref),
    initialLocation: AppRoutes.signIn,
    // Friendly error page for unknown routes (helps surface 404s in-app)
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n?.pageNotFound ?? 'Page not found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.pageNotFoundDescription ??
                    'The page you requested was not found.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.signIn),
                child: Text(l10n?.backToSignIn ?? 'Back to sign in'),
              ),
            ],
          ),
        ),
      );
    },
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
        path: AppRoutes.confirmEmail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            email: extra['email'] as String? ?? '',
            mode: extra['mode'] as OtpMode? ?? OtpMode.confirmEmail,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            email: extra['email'] as String? ?? '',
            otp: extra['otp'] as String? ?? '',
          );
        },
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
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.userProfile,
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.sellerProfile,
        builder: (context, state) => const SellerProfileScreen(),
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
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
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
          location == AppRoutes.signIn ||
          location.startsWith('/register') ||
          location.startsWith('/auth/');

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
        final roleNorm = (userRole ?? '').toString().toLowerCase();

        // --- ROLE-BASED REDIRECT LOGIC ---
        // Customers, Users and Admins should go to the unified User Home
        if (roleNorm == 'admin' ||
            roleNorm == 'customer' ||
            roleNorm == 'user') {
          // If trying to access auth routes or seller/admin-only routes, redirect to user home
          if (isGoingToAuthRoute ||
              location.startsWith('/admin') ||
              location == AppRoutes.home) {
            return AppRoutes.userHome;
          }
        }

        // Sellers / Store owners should go to the seller Home
        if (roleNorm == 'StoreOwner') {
          if (isGoingToAuthRoute ||
              location.startsWith('/user') ||
              location == AppRoutes.userHome) {
            return AppRoutes.home;
          }
        }

        // Default: if logged in and trying to access auth routes, redirect based on detected role
        if (isGoingToAuthRoute) {
          return (roleNorm == 'admin' ||
                  roleNorm == 'customer' ||
                  roleNorm == 'user')
              ? AppRoutes.userHome
              : AppRoutes.home;
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
