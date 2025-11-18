import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnteteCategorie extends StatelessWidget {
  final String titre;
  final String imagePath;

  const EnteteCategorie({
    super.key,
    required this.titre,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ), 
        ],
      ),
      child: Stack(
        children: [
          // Image d'en-tête
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dégradé sombre pour lisibilité
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Titre centré
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              titre,
              textAlign: TextAlign.center,
              style: GoogleFonts.itim(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}