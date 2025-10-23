import 'package:flutter/material.dart';
import 'payment_page.dart';
import 'detaille_produit.dart';

// La page des favoris
class FavorisPage extends StatelessWidget {
  const FavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Construit la barre d'application
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F9),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          // Remplacer par votre logo
          child: const Icon(Icons.store, color: Colors.deepOrange),
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black54, size: 28),
              onPressed: () {},
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, right: 12),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Construit le corps de la page
  Widget _buildBody() {
    // Données fictives pour les produits
  final List<Map<String, String>> products = [
      {
        'name': 'Oignons',
        'price': '30.000 fcfa',
        'weight': '(20 kg)',
        'location': 'à 33,5 km, Bamako',
        'image': 'assets/images/Oignons.png'
      },
      {
        'name': 'Carottes',
        'price': '40.000 fcfa',
        'weight': '(20 kg)',
        'location': 'à 23,5 km, Bamako',
        'image': 'assets/images/carottes.png'
      },
      {
        'name': 'Maïs',
        'price': '30.000 fcfa',
        'weight': '(20 kg)',
        'location': 'à 33,5 km, Bamako',
        'image': 'assets/images/mais.png'
      },
      {
        'name': 'Pommes',
        'price': '40.000 fcfa',
        'weight': '(20 kg)',
        'location': 'à 23,5 km, Bamako',
        'image': 'assets/images/pommes.png'
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Titre de la section
          const Text(
            'Produits (4)',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Filtres
          Row(
            children: [
              _buildFilterButton('Catégorie'),
              const SizedBox(width: 10),
              _buildFilterButton('Pays'),
            ],
          ),
          const SizedBox(height: 20),
          // Grille des produits
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
          const SizedBox(height: 80), // Espace pour le bouton flottant
        ],
      ),
    );
  }

  // Widget pour un bouton de filtre
  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(text, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        ],
      ),
    );
  }

  // Note: la barre de navigation est fournie par `MainScreen`.
}

// Widget pour la carte d'un produit
class ProductCard extends StatelessWidget {
  final Map<String, String> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit avec icônes superposées
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Tap sur l'image → page paiement
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentPage()),
                      );
                    },
                    child: Image.asset(
                      product['image']!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.favorite, color: Colors.deepOrange, size: 16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      // Ajoute au panier (placeholder)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produit ajouté au panier')));
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepOrange, width: 2),
                      ),
                      child: Center(
                        child: Icon(Icons.add, color: Colors.deepOrange, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Détails du produit
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () {
                    // Tap sur les données → page détail du produit
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductDetailsPage()),
                    );
                  },
                  child: Text(
                    product['name']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  product['weight']!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          product['location']!,
                          style: const TextStyle(color: Colors.orange, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper pour les icônes sur l'image
  Widget _buildIconButton(IconData icon, Color iconColor, {bool isAdd = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isAdd ? Colors.white.withOpacity(0.9) : Colors.transparent,
        shape: BoxShape.circle,
        border: isAdd ? null : Border.all(color: Colors.white.withOpacity(0.7)),
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 16,
        ),
      ),
    );
  }
}

