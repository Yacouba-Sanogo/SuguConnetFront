import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color grisClair = Color(0xFFD9D9D9);
const Color grisTexteChamp = Color(0xFF666666);

class ChampProfil extends StatelessWidget {
  final String label;
  final String valeur;
  final bool estMotDePasse;

  const ChampProfil({
    super.key,
    required this.label,
    required this.valeur,
    this.estMotDePasse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(label,
            style: GoogleFonts.itim(
                fontSize: 17, fontWeight: FontWeight.w400, color: Colors.black)),
        const SizedBox(height: 5),
        Container(
          height: 41,
          decoration: BoxDecoration(
            border: Border.all(color: grisClair),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            initialValue: valeur,
            obscureText: estMotDePasse,
            style: GoogleFonts.itim(fontSize: 17, color: grisTexteChamp),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
