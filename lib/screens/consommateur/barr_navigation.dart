import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';
import 'package:google_fonts/google_fonts.dart';

class BarreNavigation extends StatelessWidget {
  final int indexActif;
  final Function(int) onItemSelected;

  const BarreNavigation({
    super.key,
    required this.indexActif,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1C808080),
            offset: Offset(0, -4),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _elementNav(Icons.home, 'Accueil', 0),
          _elementNav(Icons.favorite_border, 'Favoris', 1),
          _boutonPanier(),       
          _elementNav(Icons.article, 'Commandes', 3),
          _elementNav(Icons.person, 'Profil', 4),
        ],
      ),
    );
  }

  Widget _elementNav(IconData icone, String label, int index) {
    final actif = index == indexActif;
    final couleur = actif ? orangePrincipal : Colors.black;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: couleur, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.itim(fontSize: 15, color: couleur),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boutonPanier() {
    const int indexPanier = 2; 
    return Transform.translate(
      offset: const Offset(0, -15),
      child: InkWell(
        onTap: () => onItemSelected(indexPanier), 
        child: Container(
          width: 59,
          height: 59,
          decoration: BoxDecoration(
            color: orangePrincipal,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x47000000),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
