import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/models/categorie.dart';
import 'package:suguconnect_mobile/models/produit.dart';
import 'package:suguconnect_mobile/widgets/carte_produit.dart';
import 'package:suguconnect_mobile/widgets/entete_categorie.dart';

class CategoriePage extends StatelessWidget {
  final Categorie categorie;

  const CategoriePage({super.key, required this.categorie});

  @override
  Widget build(BuildContext context) {
    final produits = [
      Produit(
        'Produit 1',
        '(10 kg)',
        '10.000 fcfa',
        'à 10 km, Bamako',
        'assets/Images/ob1.png',
      ),
      Produit(
        'Produit 2',
        '(20 kg)',
        '25.000 fcfa',
        'à 12 km, Bamako',
        'assets/Images/ob1.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categorie.nom,
          style: GoogleFonts.itim(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          EnteteCategorie(titre: categorie.nom, imagePath: ' '),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: produits.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return CarteProduit(produit: produits[index]);
              },
            ),
          ),
        ],
      ),
      //
    );
  }
}
