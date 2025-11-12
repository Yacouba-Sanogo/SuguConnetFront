import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';

class BarreNavigation extends StatefulWidget {
  final int pageIndex; 
  final Function(int) onItemTapped; 

  const BarreNavigation({
    super.key,
    required this.pageIndex,
    required this.onItemTapped,
  });

  @override
  State<BarreNavigation> createState() => BarreNavigationState();
}

class BarreNavigationState extends State<BarreNavigation> {
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
          _elementNav(Icons.article, 'Commandes', 2),
          _elementNav(Icons.person, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _elementNav(IconData icone, String label, int index) {
    final bool actif = widget.pageIndex == index;
    final couleur = actif ? orangePrincipal : Colors.black;

    return InkWell(
      onTap: () => widget.onItemTapped(index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: couleur, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.itim(
                fontSize: 15,
                color: couleur,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boutonPanier() {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: GestureDetector(
        onTap: () => widget.onItemTapped(4), 
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
