import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';
import 'package:suguconnect_mobile/models/article_panier.dart';
import 'package:suguconnect_mobile/widgets//quantite_bouton.dart';

class ElementArticle extends StatelessWidget {
  final ArticlePanier article;
  final bool estSelectionne;
  final VoidCallback lorsqueSelectionne;
  final VoidCallback lorsqueAugmente;
  final VoidCallback lorsqueDiminue;

  const ElementArticle({
    super.key,
    required this.article,
    required this.estSelectionne,
    required this.lorsqueSelectionne,
    required this.lorsqueAugmente,
    required this.lorsqueDiminue,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(article.nom), // Unique key for the Dismissible
      direction: DismissDirection.endToStart, // Swipe from right to left
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: estSelectionne
              ? null
              : Border(
                  bottom: BorderSide(color: grisClair.withValues(alpha: .5), width: 1),
                ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: lorsqueSelectionne,
              child: Container(
                width: 15,
                height: 15,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: estSelectionne ? orangePrincipal : Colors.white,
                  border: Border.all(
                    color: estSelectionne ? orangePrincipal : grisClair,
                    width: 1,
                  ),
                ),
                child: estSelectionne
                    ? const Icon(Icons.check, color: Colors.white, size: 10)
                    : null,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.asset(
                article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(article.nom, style: GoogleFonts.itim(fontSize: 15)),
                  Text(
                    'Producteur : ${article.producteur}',
                    style: GoogleFonts.itim(fontSize: 15),
                  ),
                  Text(
                    article.prixUnitaire,
                    style: GoogleFonts.itim(fontSize: 15),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                BoutonQuantite(
                  icone: Icons.remove,
                  article: article,
                  estIncrement: false,
                  lorsqueAppuye: lorsqueDiminue,
                ),
                const SizedBox(width: 8),
                Text(
                  '${article.quantite}',
                  style: GoogleFonts.itim(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(width: 8),
                BoutonQuantite(
                  icone: Icons.add,
                  article: article,
                  estIncrement: true,
                  lorsqueAppuye: lorsqueAugmente,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}