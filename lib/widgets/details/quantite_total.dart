import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color couleurQuantiteFond = Color(0xFFD9D9D9);
const Color couleurDisponible = Color(0xFF3A6F43);

class QuantiteEtTotal extends StatelessWidget {
  final int quantite;
  final VoidCallback increment;
  final VoidCallback decrement;
  final double prixTotal;

  const QuantiteEtTotal({
    super.key,
    required this.quantite,
    required this.increment,
    required this.decrement,
    required this.prixTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    
      children: [
        SizedBox(height: 19,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Quantité", style: GoogleFonts.itim(fontSize: 20)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: couleurDisponible,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Disponible",
                style: GoogleFonts.itim(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Prix total : ${prixTotal.toStringAsFixed(0)} fcfa",
              style: GoogleFonts.itim(fontSize: 20, color: Colors.orange),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: couleurQuantiteFond,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: decrement,
                    child: Text("-", style: GoogleFonts.itim(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Text("$quantite", style: GoogleFonts.itim(fontSize: 20)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: increment,
                    child: Text("+", style: GoogleFonts.itim(fontSize: 22)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}