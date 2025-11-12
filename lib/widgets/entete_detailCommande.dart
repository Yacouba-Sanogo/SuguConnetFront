import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color grisFermeture = Color(0x33000000);

class EnteteDetailsCommande extends StatelessWidget {
  const EnteteDetailsCommande({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: grisFermeture,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.black, size: 20),
          ),
        ),
        Text(
          'Détails de la commande',
          style: GoogleFonts.itim(fontSize: 24, fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}
