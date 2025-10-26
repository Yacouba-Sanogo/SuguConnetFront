import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
import 'package:suguconnect_mobile/screens/producer/producer_dashboard_screen.dart';
import 'package:suguconnect_mobile/screens/producer/producer_products_screen.dart';
import 'package:suguconnect_mobile/screens/producer/producer_orders_screen.dart';
import 'package:suguconnect_mobile/screens/producer/producer_profile_screen.dart';

// Écran principal de l'interface producteur avec navigation par onglets
class ProducerMainScreen extends StatefulWidget {
  const ProducerMainScreen({super.key});

  @override
  State<ProducerMainScreen> createState() => _ProducerMainScreenState();
}

class _ProducerMainScreenState extends State<ProducerMainScreen> {
  // Index de la page actuellement sélectionnée
  int _currentIndex = 0;

  // Liste des pages disponibles dans l'interface producteur
  late final List<Widget> _pages = <Widget>[
    const ProducerDashboardScreen(), // Tableau de bord
    const ProducerProductsScreen(), // Gestion des produits
    const ProducerOrdersScreen(), // Commandes
    const ProducerProfileScreen(), // Profil producteur
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: AppTheme.primaryColor.withAlpha(31),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Produits'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Commandes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}



