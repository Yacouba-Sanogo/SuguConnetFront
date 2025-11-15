import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiseEnPageAuthentification extends StatelessWidget {
  final Widget entete;
  final Widget formulaire;

  const MiseEnPageAuthentification({
    super.key,
    required this.entete,
    required this.formulaire,
  });

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.of(context).size.width;
    final margeHorizontale = largeur * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            entete,
            Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0.0, -40.0, 0.0),
              margin: const EdgeInsets.only(bottom: 40.0),
              padding: EdgeInsets.fromLTRB(margeHorizontale, 30, margeHorizontale, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29000000),
                    offset: Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: GoogleFonts.itim(fontSize: 16, color: Colors.black87),
                child: formulaire,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
