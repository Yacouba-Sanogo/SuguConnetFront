import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/landing_page.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), 
      ],
      child: MaterialApp(
        title: 'SuguConnect', 
        theme: AppTheme.lightTheme, 
        debugShowCheckedModeBanner: false, 
        home: const LandingPage(), 
        // Configuration des routes de navigation
        // routes: {
        //   '/landing': (context) => const LandingPage(), // Page d'accueil
        //   '/login': (context) => const LoginScreen(), // Connexion
        //   '/register': (context) => const RegisterScreen(), // Inscription
        //   '/role-selection': (context) => const RoleSelectionScreen(), // Sélection de rôle
        //   '/consumer': (context) => MainScreen(), // Interface consommateur
        //   '/consumer/catalog': (context) => const ProductCatalogScreen(), // Catalogue produits
        //   '/consumer/cart': (context) => const ShoppingCartScreen(), // Panier
        //   '/consumer/notifications': (context) => const NotificationsPage(), // Notifications
        //   '/producer': (context) => const ProducerMainScreen(), // Interface producteur
        //   '/producer/products': (context) => const ProductManagementScreen(), // Gestion produits
        //   '/producer/profile': (context) => const ProducerProfileScreen(), // Profil producteur
        // },
      ),
    );
  }
}
