import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';
import 'package:suguconnect_mobile/models/article_panier.dart';

class BoutonQuantite extends StatelessWidget {
  final IconData icone;
  final ArticlePanier article;
  final bool estIncrement;
  final VoidCallback lorsqueAppuye;

  const BoutonQuantite({
    super.key,
    required this.icone,
    required this.article,
    required this.estIncrement,
    required this.lorsqueAppuye,
  });

  @override
  Widget build(BuildContext context) {
    final couleurFond = estIncrement ? orangePrincipal : grisClair;
    final couleurIcone = estIncrement ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: lorsqueAppuye,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: couleurFond,
        ),
        child: Icon(icone, size: 13, color: couleurIcone),
      ),
    );
  }
}
