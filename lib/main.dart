import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/landing_page.dart';
import 'screens/consumer/main_screen.dart';
import 'screens/consumer/product_catalog_screen.dart';
import 'screens/consumer/panier.dart';
import 'screens/consumer/notifications_page.dart';
import 'screens/producer/producer_dashboard_screen.dart';
import 'screens/producer/producer_main_screen.dart';
import 'screens/producer/product_management_screen.dart';
import 'screens/producer/producer_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
 import 'screens/consumer/acceuil.dart';

// Point d'entrée principal de l'application SuguConnect
void main() {
  runApp(const MyApp());
}

// Widget principal de l'application avec configuration des routes
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Fournisseurs de données globales (Provider pour l'état)
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Gestionnaire d'authentification
      ],
      child: MaterialApp(
        title: 'SuguConnect', // Nom de l'application
        theme: AppTheme.lightTheme, // Thème personnalisé
        debugShowCheckedModeBanner: false, // Masquer la bannière de debug
        home: const LandingPage(), // Page d'accueil (landing page)
        // Configuration des routes de navigation
        routes: {
          '/landing': (context) => const LandingPage(), // Page d'accueil
          '/login': (context) => const LoginScreen(), // Connexion
          '/register': (context) => const RegisterScreen(), // Inscription
          '/role-selection': (context) => const RoleSelectionScreen(), // Sélection de rôle
          '/consumer': (context) => MainScreen(), // Interface consommateur
          '/consumer/catalog': (context) => const ProductCatalogScreen(), // Catalogue produits
          '/consumer/cart': (context) => const CartPage(), // Panier
          '/consumer/notifications': (context) => const NotificationsPage(), // Notifications
          '/producer': (context) => const ProducerMainScreen(), // Interface producteur
          '/producer/products': (context) => const ProductManagementScreen(), // Gestion produits
          '/producer/profile': (context) => const ProducerProfileScreen(), // Profil producteur
        },
      ),
    );
  }
}
