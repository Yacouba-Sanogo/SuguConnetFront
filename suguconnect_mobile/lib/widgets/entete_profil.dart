import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';

const Color orangePrincipal = Color(0xFFFB662F);
const Color couleurDeconnexionFond = Color(0xFFE43636);

class EnteteProfil extends StatelessWidget {
  final String nomComplet;
  final VoidCallback? onLogout;

  const EnteteProfil({super.key, required this.nomComplet, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: orangeVif.withValues(alpha: 0.30),
              ),
              child: Icon(
                Icons.account_circle,
                size: 80,
                color: orangePrincipal.withValues(alpha: 0.31),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                nomComplet,
                style: GoogleFonts.itim(fontSize: 26, color: Colors.black),
              ),
            ),
            GestureDetector(
              onTap: onLogout,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: couleurDeconnexionFond,
                ),
                child: Icon(Symbols.chip_extraction, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
