import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/models/favoris_manager.dart';
import 'package:suguconnect_mobile/widgetS/carte_produit.dart';
import 'package:suguconnect_mobile/widgets/entete_widget.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EnteteWidget(),
      body: GestionnaireFavoris.favorisProduit.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Aucun favori pour le moment",
                    style: GoogleFonts.itim(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Cliquez sur le cœur dans les produits pour les ajouter ici",
                    style: GoogleFonts.itim(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: GestionnaireFavoris.favorisProduit.length,
                itemBuilder: (context, index) {
                  return CarteProduit(produit: GestionnaireFavoris.favorisProduit[index]);
                },
              ),
            ),
    );
  }
}