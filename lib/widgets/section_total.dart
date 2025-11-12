import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';

class SectionTotal extends StatelessWidget {
  final String totalGeneral;

  const SectionTotal({super.key, required this.totalGeneral});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Divider(color: grisClair, thickness: 2, height: 20),
          Text(
            'Total : $totalGeneral',
            style: GoogleFonts.itim(fontSize: 15, color: Colors.black),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
