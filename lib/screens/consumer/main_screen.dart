import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'acceuil.dart';
import 'favoris_page.dart';
import 'commandes_page.dart';
import 'profil_page.dart';
import '../../widgets/entete_widget.dart';
import '../../widgets/bottom_navigation_bar_widget.dart';

// Écran principal de l'interface consommateur avec navigation par onglets
class MainScreen extends StatefulWidget {
  final int? initialIndex;
  
  const MainScreen({super.key, this.initialIndex});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index de la page actuellement sélectionnée
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  // Liste des pages disponibles dans l'interface consommateur
  final List<Widget> _pages = [
    AccueilPage(), // Page d'accueil
    FavorisPage(), // Page des produits (ancien comportement)
    CommandesPage(), // Page des commandes
    ProfilPage(), // Page de profil
  ];

  @override
  Widget build(BuildContext context) {
    // Déterminer si la page actuelle doit avoir un appBar
    final bool showAppBar = _currentIndex == 1 || _currentIndex == 2; // Favoris ou Commandes
    
    return Scaffold(
      appBar: showAppBar ? const EnteteWidget() : null,
      // Animated switcher for smooth page transitions when tapping bottom items
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
        child: Container(
          key: ValueKey(_currentIndex),
          child: _currentIndex == 1 
            ? FavorisPage(showAppBar: false)
            : _currentIndex == 2
              ? CommandesPage(showAppBar: false)
              : _currentIndex == 3
                ? ProfilPage(showAppBar: false)
                : _pages[_currentIndex],
        ),
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
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}