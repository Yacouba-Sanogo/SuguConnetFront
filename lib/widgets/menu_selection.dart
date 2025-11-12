import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';

class MenuSelection extends StatelessWidget {
  final String valeur;
  final List<String> options;
  final ValueChanged<String?> lorsqueChange;

  const MenuSelection({
    super.key,
    required this.valeur,
    required this.options,
    required this.lorsqueChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: grisClair, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: valeur,
                icon: const Icon(Icons.keyboard_arrow_down_sharp,
                    color: Colors.black, size: 24),
                style: GoogleFonts.itim(fontSize: 17, color: Colors.black),
                items: options
                    .map((String option) =>
                        DropdownMenuItem(value: option, child: Text(option)))
                    .toList(),
                onChanged: lorsqueChange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
