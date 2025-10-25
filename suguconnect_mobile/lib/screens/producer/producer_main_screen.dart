import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
import 'package:suguconnect_mobile/screens/producer/producer_dashboard_screen.dart';
import 'package:suguconnect_mobile/screens/producer/product_management_screen.dart';
import 'package:suguconnect_mobile/screens/producer/producer_orders_screen.dart';

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
    const ProductManagementScreen(), // Gestion des produits
    const ProducerOrdersScreen(), // Commandes
    const _ProducerProfilePlaceholder(), // Profil (placeholder)
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
        indicatorColor: AppTheme.primaryColor.withOpacity(0.12),
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

class _ProducerProfilePlaceholder extends StatelessWidget {
  const _ProducerProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(
        child: Text('Profil producteur (à compléter)'),
      ),
    );
  }
}


