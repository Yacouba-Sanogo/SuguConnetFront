import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color fondProducteur = Color(0x4DD9D9D9);

class InfoProducteur extends StatelessWidget {
  final String nom;
  final String ferme;
  final String description;
  final String image;

  const InfoProducteur({
    super.key,
    required this.nom,
    required this.ferme,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: fondProducteur),
      child: Row(
        children: [
          const SizedBox(width: 10),

          // Photo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            ),
          ),

          const SizedBox(width: 15),

          // Texte
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Producteur : $nom",
                style: GoogleFonts.itim(fontSize: 19),
              ),
              Text(
                "Ferme : $ferme",
                style: GoogleFonts.itim(fontSize: 15),
              ),
              Text(
                description,
                style: GoogleFonts.itim(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
