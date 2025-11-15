import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/models/categorie.dart';
import 'package:suguconnect_mobile/models/produit.dart';
import 'package:suguconnect_mobile/widgets/image_entete.dart';
import 'package:suguconnect_mobile/screens/consommateur/categorie_page.dart';
import 'package:suguconnect_mobile/widgets/categorie_item.dart';
import 'package:suguconnect_mobile/widgets/carte_produit.dart';

const Color orangePrincipal = Color(0xFFFB662F);

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Liste des catégories ---
    final List<Categorie> categories = [
       Categorie('Légumes', 'assets/icons/legumes.png', Color(0x4D8FA31E)),
       Categorie(
        'Céréales',
        'assets/icons/cereales.png',
        Color(0x33FFFF00),
      ),
       Categorie(
        'Liquides',
        'assets/icons/liquides.png',
        Color(0x4D640D5F),
      ),
      Categorie('Épices', 'assets/icons/epices.png', Color(0x4CDC143C)),
      Categorie('Graines', 'assets/icons/graines.png', Color(0x4DB6771D)),
    ];
    // --- Liste des produits ---
    final List<Produit> produits = [
      Produit(
        'Mangues',
        '(20 kg)',
        '30.000 fcfa',
        'à 33,5 km , Bamako',
        'assets/images/ob1.png',
      ),
      Produit(
        'Oranges',
        '(20 kg)',
        '40.000 fcfa',
        'à 23,5 km , Bamako',
        'assets/images/ob1.png',
      ),
      Produit(
        'Oranges',
        '(20 kg)',
        '40.000 fcfa',
        'à 23,5 km , Bamako',
        'assets/images/ob1.png',
      ),
    ];

    // --- Structure principale de la page ---
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Permet le défilement vertical
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EnteteAccueil(),
            _titreSection('Découvrir par catégorie'),
            _grilleCategories(categories),
            _titreSection('Des produits que vous pourriez aimer'),
            _listeProduits(produits),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  // --- Widget titre de section ---
  Widget _titreSection(String texte) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Text(
        texte,
        style: GoogleFonts.itim(
          fontSize: 20,
          color: orangePrincipal,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Grille des catégories ---
  Widget _grilleCategories(List<Categorie> categories) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categorie = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoriePage(categorie: categorie),
                ),
              );
            },
            child: ElementCategorie(categorie: categorie),
          );
        },
      ),
    );
  }

  // --- Liste horizontale de produits ---
  Widget _listeProduits(List<Produit> produits) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: produits.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 1.0, bottom: 2.0),
            child: CarteProduit(produit: produits[index]),
          );
        },
      ),
    );
  }
}
