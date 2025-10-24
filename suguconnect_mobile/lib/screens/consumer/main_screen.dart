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
    FavorisPage(), // Page des favoris
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

      // BottomAppBar with notch so the FAB visually docks into it while keeping its circular shape
      bottomNavigationBar: Container(
        height: 70, // Hauteur totale de la barre
        child: Stack(
          children: [
            // Fond de la barre de navigation qui prend toute la largeur
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 0), // Pas de marge horizontale
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
              ),
            ),
            // Barre de navigation positionnée au-dessus du fond
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Répartit l'espace équitablement
                  children: [
                    // Bouton Accueil
                    _buildNavItem(
                      icon: Icons.home,
                      label: 'Accueil',
                      index: 0,
                    ),
                    // Bouton Favoris
                    _buildNavItem(
                      icon: Icons.favorite,
                      label: 'Favoris',
                      index: 1,
                    ),
                    // Espace pour le FAB (invisible mais nécessaire pour l'alignement)
                    SizedBox(width: 60),
                    // Bouton Commandes
                    _buildNavItem(
                      icon: Icons.shopping_cart,
                      label: 'Commandes',
                      index: 2,
                    ),
                    // Bouton Profil
                    _buildNavItem(
                      icon: Icons.person,
                      label: 'Profil',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    return Expanded( // Chaque élément prend un espace égal
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          splashColor: Color(0xFFFB662F).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? Color(0xFFFB662F) : Colors.black54,
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 10,
                    color: isSelected ? Color(0xFFFB662F) : Colors.black54,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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