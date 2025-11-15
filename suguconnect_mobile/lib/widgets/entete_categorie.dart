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
      width: double.infinity,
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Text(
          titre,
          style: GoogleFonts.jaldi(
            fontSize: 59,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
