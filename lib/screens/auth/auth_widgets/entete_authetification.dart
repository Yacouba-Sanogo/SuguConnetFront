import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';

class EnteteAuthentification extends StatelessWidget {
  final String titre;

  const EnteteAuthentification({super.key, required this.titre});
  @override
  Widget build(BuildContext context) {
    final marge = MediaQuery.of(context).size.width * 0.06;

    return Container(
      width: double.infinity,
      height: 280,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        left: marge,
        right: marge,
      ),
      decoration: const BoxDecoration(color: fondEntete),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Bouton retour
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
            ),
          ),
          const SizedBox(height: 20),
          // Texte principal
          Text(
            titre,
            style: GoogleFonts.itim(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
