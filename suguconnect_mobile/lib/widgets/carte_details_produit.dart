import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/models/detail_commande.dart';

class CarteDetailsProduit extends StatelessWidget {
  final DetailCommande commande;

  const CarteDetailsProduit({super.key, required this.commande});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Commande ${commande.numero}',
              style: GoogleFonts.itim(fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 117,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: AssetImage(commande.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailLine('Producteur', commande.producteur),
                    _buildDetailLine('Produit', commande.produit),
                    _buildDetailLine('Quantité', commande.quantite.toString()),
                    _buildDetailLine(
                        'Prix unitaire', '${commande.prixUnitaire} fcfa'),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Prix total : ${commande.prixTotal} fcfa',
                        style: GoogleFonts.itim(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text('$label : $value',
          style: GoogleFonts.itim(fontSize: 15, color: Colors.black)),
    );
  }
}
