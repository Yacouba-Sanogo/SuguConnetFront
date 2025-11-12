import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color grisClair = Color(0xFFD9D9D9);
const Color grisTexteChamp = Color(0xFF666666);

class ChampTelephoneProfil extends StatelessWidget {
  final String label;
  final String codePays;
  final String numero;

  const ChampTelephoneProfil({
    super.key,
    required this.label,
    required this.codePays,
    required this.numero,
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
        Row(
          children: [
            Container(
              width: 91,
              height: 41,
              decoration: BoxDecoration(
                border: Border.all(color: grisClair),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(codePays,
                      style:
                          GoogleFonts.itim(fontSize: 17, color: grisTexteChamp)),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 41,
                decoration: BoxDecoration(
                  border: Border.all(color: grisClair),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  initialValue: numero,
                  keyboardType: TextInputType.phone,
                  style:
                      GoogleFonts.itim(fontSize: 17, color: grisTexteChamp),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
