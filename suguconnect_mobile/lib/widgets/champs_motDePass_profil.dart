import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color grisClair = Color(0xFFD9D9D9);
const Color grisTexteChamp = Color(0xFF666666);

class ChampsMotDePasseProfil extends StatelessWidget {
  const ChampsMotDePasseProfil({super.key});

  Widget _champ(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(label,
              style: GoogleFonts.itim(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
        if (label.isNotEmpty) const SizedBox(height: 5),
        Container(
          height: 41,
          decoration: BoxDecoration(
            border: Border.all(color: grisClair),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            initialValue: '*******',
            obscureText: true,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _champ('Mot de passe')),
            const SizedBox(width: 10),
            Expanded(child: _champ('Nouveau mot de passe')),
          ],
        ),
        const SizedBox(height: 15),
        _champ('Confirmer le nouveau mot de passe'),
      ],
    );
  }
}
