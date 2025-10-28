import 'package:flutter/material.dart';
import 'acceuil.dart';
import 'favoris_page.dart';
import 'commandes_page.dart';
import 'profil_page.dart';

// Écran principal de l'interface consommateur avec navigation par onglets
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index de la page actuellement sélectionnée
  int _currentIndex = 0;

  // Liste des pages disponibles dans l'interface consommateur
  final List<Widget> _pages = [
    AccueilPage(), // Page d'accueil
    FavorisPage(), // Page des produits (anciennement favoris)
    CommandesPage(), // Page des commandes
    ProfilPage(), // Page de profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Animated switcher for smooth page transitions when tapping bottom items
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
        child: _pages[_currentIndex],
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
          );
        },
      ),

      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/consumer/cart'),
          backgroundColor: const Color(0xFFFB662F),
          elevation: 8,
          shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 6)),
          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BottomNavigationBar simple et propre comme dans l'image
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
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
                  icon: Icons.receipt_long_outlined,
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
          splashColor: Color(0xFFFB662F).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? Color(0xFFFB662F) : Colors.black,
                ),
                SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Color(0xFFFB662F) : Colors.black,
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