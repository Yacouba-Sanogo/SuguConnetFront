import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/categorie.dart';

class ElementCategorie extends StatelessWidget {
  final Categorie categorie;

  const ElementCategorie({super.key, required this.categorie});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: categorie.couleurFond,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            categorie.icone,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 5),
          Text(
            categorie.nom,
            style: GoogleFonts.itim(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
