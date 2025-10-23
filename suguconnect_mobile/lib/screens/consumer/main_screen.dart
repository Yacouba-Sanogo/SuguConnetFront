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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFFFB662F),
                  unselectedItemColor: Colors.black54,
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 14,
                  unselectedFontSize: 12,
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home, size: 26), label: 'Accueil'),
                    BottomNavigationBarItem(icon: Icon(Icons.favorite, size: 26), label: 'Favoris'),
                    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart, size: 26), label: 'Commandes'),
                    BottomNavigationBarItem(icon: Icon(Icons.person, size: 26), label: 'Profil'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
