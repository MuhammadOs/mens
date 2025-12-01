import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mens/core/routing/app_router.dart';
// Theme provider import removed; using Theme.of(context) directly

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print(
      'RoleSelectionScreen.build called, current path: ${ModalRoute.of(context)?.settings.name ?? Uri.base.path}',
    );
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Placeholder
              // Logo (app image)
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage('assets/mens_logo.png'),
              ),
              const SizedBox(height: 50),

              // The Card Container
              Container(
                width: 300,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(
                    0.5,
                  ), // Semi-transparent card
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Register as",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Button 1: Gentleman
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Customer Registration
                          context.go(AppRoutes.registerCustomer);
                        },
                        child: const Text(
                          "Gentleman",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Button 2: Partner
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Partner Registration (register form)
                          context.go(AppRoutes.register);
                        },
                        child: const Text(
                          "Partner",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
