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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton Accueil
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Accueil',
                  index: 0,
                ),
                // Bouton Produits
                _buildNavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Produits',
                  index: 1,
                ),
                // Bouton Commandes
                _buildNavItem(
                  icon: Icons.article,
                  label: 'Commandes',
                  index: 2,
                ),
                // Bouton Profil
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour créer un élément de navigation
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          splashColor: AppTheme.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppTheme.primaryColor : Colors.black,
                ),
                SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? AppTheme.primaryColor : Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



