import 'package:flutter/material.dart';

class ChampTexte extends StatelessWidget {
  final String indication;
  final bool texteMasque;
  final TextInputType? typeClavier;

  const ChampTexte({
    super.key,
    required this.indication,
    this.texteMasque = false,
    this.typeClavier,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: texteMasque,
      keyboardType: typeClavier,
      decoration: InputDecoration(
        labelText: indication,
        labelStyle: const TextStyle(
          fontFamily: 'Itim',
          fontSize: 16,
          color: Colors.black54,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
