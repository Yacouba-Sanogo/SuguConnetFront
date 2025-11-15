import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/widgets/carrousel_image.dart';
import 'package:suguconnect_mobile/widgets/details/quantite_total.dart';
import 'package:suguconnect_mobile/widgets/info_producteur.dart';
import 'package:suguconnect_mobile/widgets/produit_detail.dart';
import 'package:suguconnect_mobile/widgets/bouton_principale.dart';
import 'package:suguconnect_mobile/models/favoris_manager.dart';

const Color fondHeader = Color(0x1AFB662F);
const Color orangePrincipal = Color(0xFFFB662F);

class DetailsProduitPage extends StatefulWidget {
  final ProduitDetail produit;

  const DetailsProduitPage({super.key, required this.produit});

  @override
  State<DetailsProduitPage> createState() => _DetailsProduitPageState();
}

class _DetailsProduitPageState extends State<DetailsProduitPage> {
  int _quantite = 1;

  bool get _estFavori =>
      GestionnaireFavoris.estFavoriProduitDetail(widget.produit);

  void increment() => setState(() => _quantite++);
  void decrement() =>
      setState(() => _quantite = _quantite > 1 ? _quantite - 1 : 1);

  void _basculerFavori() {
    setState(() {
      GestionnaireFavoris.basculerFavoriProduitDetail(widget.produit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double prixTotal = widget.produit.prix * _quantite;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: fondHeader,
        title: Text("Détails produit", style: GoogleFonts.itim(fontSize: 26)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: CarrouselImages(images: widget.produit.images),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITRE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.produit.nom,
                        style: GoogleFonts.itim(fontSize: 26),
                      ),
                      GestureDetector(
                        onTap: _basculerFavori,
                        child: Icon(
                          _estFavori ? Icons.favorite : Icons.favorite_border,
                          color: _estFavori ? orangePrincipal : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // PRODUCTEUR
                  InfoProducteur(
                    nom: widget.produit.producteurNom,
                    ferme: widget.produit.producteurFerme,
                    description: widget.produit.producteurDescription,
                    image: widget.produit.producteurImage,
                  ),

                  const SizedBox(height: 10),

                  // PRIX ET UNITE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Prix : ${widget.produit.prix} fcfa",
                        style: GoogleFonts.itim(
                          fontSize: 20,
                          color: orangePrincipal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: orangePrincipal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.produit.unite,
                          style: GoogleFonts.itim(color: orangePrincipal),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  // QUANTITÉ
                  
                  QuantiteEtTotal(
                    quantite: _quantite,
                    prixTotal: prixTotal,
                    increment: increment,
                    decrement: decrement,
                  ),

                  const SizedBox(height: 20),
                  // DESCRIPTION
                  Text("Description", style: GoogleFonts.itim(fontSize: 20)),
                  const SizedBox(height: 5),
                  Text(
                    widget.produit.description,
                    style: GoogleFonts.itim(fontSize: 16),
                  ),

                  const SizedBox(height: 20),
                  BoutonPrincipal(
                    texte: 'Ajouter au panier',
                    onPressed: () {
                      // Action d’achat
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
