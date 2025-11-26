import 'package:flutter/material.dart';

class EnteteAccueil extends StatelessWidget {
  const EnteteAccueil({super.key});

  // Définition de l'opacité noire (50%)
  static const Color overlayColor = Color(0x80000000); 

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/accueil.jpg'), 
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: overlayColor, 
      ),
    );
  }
}