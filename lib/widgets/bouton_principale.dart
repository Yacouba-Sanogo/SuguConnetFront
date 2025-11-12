import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';

class BoutonPrincipal extends StatelessWidget {
  final String texte; // le texte du bouton
  final VoidCallback onPressed; // action au clic
  final Color? couleur; // couleur de fond 
  final double hauteur; // hauteur du bouton
  final double rayonBordure; // coins arrondis
  final TextStyle? styleTexte; // style personnalisé du texte
  final EdgeInsetsGeometry? marge; // pour gérer les marges

  const BoutonPrincipal({
    super.key,
    required this.texte,
    required this.onPressed,
    this.couleur,
    this.hauteur = 60,
    this.rayonBordure = 10,
    this.styleTexte,
    this.marge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: marge ?? const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: hauteur,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: couleur ?? orangePrincipal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rayonBordure),
            ),
            elevation: 2,
          ),
          child: Text(
            texte,
            style: styleTexte ??
                GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
