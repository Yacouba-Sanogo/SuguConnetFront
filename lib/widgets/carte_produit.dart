import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';
import 'package:suguconnect_mobile/models/produit.dart';
import 'package:suguconnect_mobile/models/favoris_manager.dart';
import 'package:suguconnect_mobile/screens/consommateur/detail_produit.dart' as detail;
import 'package:suguconnect_mobile/widgets/produit_detail.dart';

class CarteProduit extends StatefulWidget {
  final Produit produit;

  const CarteProduit({super.key, required this.produit});

  @override
  State<CarteProduit> createState() => _CarteProduitState();
}

class _CarteProduitState extends State<CarteProduit> {
  bool get _isFavori => GestionnaireFavoris.estFavori(widget.produit);

  void _toggleFavori() {
    setState(() {
      GestionnaireFavoris.estFavori(widget.produit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final produitDetail = ProduitDetail(
          nom: widget.produit.nom,
          prix: double.tryParse(
                widget.produit.prix.replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0.0,
          unite: widget.produit.poids,
          images: [widget.produit.image, widget.produit.image, widget.produit.image],
          description: "Description détaillée du produit ${widget.produit.nom}",
          producteurNom: "Nom",
          producteurFerme: "Ferme du producteur",
          producteurDescription: "Description du producteur",
          producteurImage: widget.produit.image,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                detail.DetailsProduitPage(produit: produitDetail),
          ),
        );
      },
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image avec icône favori ---
            Stack(
              children: [
                Flexible(
                  flex: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Image.asset(
                      widget.produit.image,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavori,
                    onTapDown: (_) => _toggleFavori(), 
                    child: Icon(
                      _isFavori ? Icons.favorite : Icons.favorite_border,
                      color: _isFavori ? orangePrincipal : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            // --- Partie texte flexible qui s'adapte ---
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bloc supérieur : nom / poids / prix
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.produit.nom,
                          style: GoogleFonts.itim(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.produit.poids,
                          style: GoogleFonts.itim(
                            fontSize: 13,
                            color: couleurSousTitre,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.produit.prix,
                          style: GoogleFonts.itim(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Bloc inférieur : localisation
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: fondLocalisation,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: orangePrincipal,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.produit.localisation,
                              style: GoogleFonts.itim(
                                fontSize: 13,
                                color: orangePrincipal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}