import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'consumer/main_screen.dart';
import 'producer/producer_dashboard_screen.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Rediriger vers l'écran approprié selon le rôle
        switch (authProvider.userRole) {
          case 'CONSOMMATEUR':
            return MainScreen();
          case 'PRODUCTEUR':
            return const ProducerDashboardScreen();
          case 'ADMIN':
            return const ProducerDashboardScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
