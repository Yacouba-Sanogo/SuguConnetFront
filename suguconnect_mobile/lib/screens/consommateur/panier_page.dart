import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';
import 'package:suguconnect_mobile/models/article_panier.dart';
import 'package:suguconnect_mobile/widgets/article_item.dart';
import 'package:suguconnect_mobile/widgets/bouton_principale.dart';
import 'package:suguconnect_mobile/widgets/entete_widget.dart';
import 'package:suguconnect_mobile/widgets/section_total.dart';

class PagePanier extends StatefulWidget {
  const PagePanier({super.key});

  @override
  State<PagePanier> createState() => _PagePanierState();
}

class _PagePanierState extends State<PagePanier> {
  final List<ArticlePanier> articles = [
    ArticlePanier(
      nom: 'Choux',
      producteur: 'Ali Touré',
      prixUnitaire: '30.000 fcfa',
      imageUrl: 'assets/images/deuxieme.png',
      quantite: 1,
    ),
  ];

  String? articleSelectionne = 'Choux';
  final String totalGeneral = '30.000 fcfa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EnteteWidget(),
      backgroundColor: grisClair.withValues(alpha: 0.1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 10),
            ...articles.map(
              (article) => ElementArticle(
                article: article,
                estSelectionne: article.nom == articleSelectionne,
                lorsqueSelectionne: () {
                  setState(() {
                    articleSelectionne = article.nom == articleSelectionne
                        ? null
                        : article.nom;
                  });
                },
                lorsqueAugmente: () {
                  setState(() {
                    article.quantite++;
                  });
                },
                lorsqueDiminue: () {
                  setState(() {
                    if (article.quantite > 1) article.quantite--;
                  });
                },
              ),
            ),
            SectionTotal(totalGeneral: totalGeneral),
            BoutonPrincipal(
              texte: 'Acheter',
              onPressed: () {
                // Action d’achat
              },
              hauteur: 60,
              rayonBordure: 5,
              styleTexte: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
