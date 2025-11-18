import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/models/categorie.dart';
import 'package:suguconnect_mobile/models/produit.dart';
import 'package:suguconnect_mobile/widgets/carte_produit.dart';
import 'package:suguconnect_mobile/widgets/champs_tel_profil.dart';
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
        'assets/images/ob1.png',
      ),
      Produit(
        'Produit 2',
        '(20 kg)',
        '25.000 fcfa',
        'à 12 km, Bamako',
        'assets/images/ob1.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              hintStyle: GoogleFonts.itim(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: GoogleFonts.itim(color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // Action pour le filtre
            },
          ),
        ],
      ),
      body: Column(
        children: [
         SizedBox(height: 16), 
          EnteteCategorie(
            titre: categorie.nom,
            imagePath: categorie.imageEntete,
          ),
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