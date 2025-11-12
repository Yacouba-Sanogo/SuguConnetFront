import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

// Page réutilisable pour une catégorie (Fruits, Céréales, Légumes, Épices...)
class FruitPage extends StatefulWidget {
  final String title;
  final String headerImage; // chemin local ou URL

  const FruitPage({Key? key, required this.title, required this.headerImage}) : super(key: key);

  @override
  State<FruitPage> createState() => _FruitPageState();
}

class _FruitPageState extends State<FruitPage> {
  // Liste complète des produits
  final List<Map<String, dynamic>> _allProducts = [
    // We'll leave product data minimal; images will be chosen per-category below
    {'id': 1, 'name': 'Produit 1', 'weight': '20 kg', 'price': 30000.0, 'location': 'à 33,5 km, Bamako', 'image': '', 'isFavorite': false, 'isAvailable': true},
    {'id': 2, 'name': 'Produit 2', 'weight': '20 kg', 'price': 40000.0, 'location': 'à 23,5 km, Bamako', 'image': '', 'isFavorite': true, 'isAvailable': true},
    {'id': 3, 'name': 'Produit 3', 'weight': '20 kg', 'price': 35000.0, 'location': 'à 33,5 km, Bamako', 'image': '', 'isFavorite': false, 'isAvailable': true},
    {'id': 4, 'name': 'Produit 4', 'weight': '50 kg', 'price': 50000.0, 'location': 'à 33,5 km, Bamako', 'image': '', 'isFavorite': false, 'isAvailable': false},
    {'id': 5, 'name': 'Produit 5', 'weight': '30 kg', 'price': 30000.0, 'location': 'à 23,5 km, Bamako', 'image': '', 'isFavorite': true, 'isAvailable': true},
    {'id': 6, 'name': 'Produit 6', 'weight': '50 kg', 'price': 100000.0, 'location': 'à 33,5 km, Bamako', 'image': '', 'isFavorite': false, 'isAvailable': true},
  ];

  late List<Map<String, dynamic>> _filteredProducts;
  String? _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Mangues', 'Oranges', 'Poires', 'Papayes', 'Pommes', 'Ananas'];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    // Assign sample images depending on the category title
    final lower = widget.title.toLowerCase();
    String sample;
    if (lower.contains('fruit')) {
      sample = 'assets/images/pommes.png';
    } else if (lower.contains('céré') || lower.contains('cere')) {
      sample = 'assets/images/mais.png';
    } else if (lower.contains('lég') || lower.contains('leg')) {
      sample = 'assets/images/carottes.png';
    } else if (lower.contains('épice') || lower.contains('epic')) {
      sample = 'assets/images/Oignons.png';
    } else {
      sample = 'assets/images/pommes.png';
    }
    for (var p in _allProducts) {
      p['image'] = sample;
    }
  }
  
  // Fonction pour filtrer les produits
  void _filterProducts(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Tous') {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) => product['name'] == filter).toList();
      }
    });
  }

  // Fonction pour basculer l'état de favori
  void _toggleFavorite(int id) {
    setState(() {
      final productIndex = _allProducts.indexWhere((p) => p['id'] == id);
      if (productIndex != -1) {
        _allProducts[productIndex]['isFavorite'] = !_allProducts[productIndex]['isFavorite'];
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderImage()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          _buildProductGrid(),
        ],
      ),
      // This page does not provide its own BottomNavigationBar: the app's main
      // BottomNavigationBar (in MainScreen) must remain the single primary one.
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black54),
          onPressed: () {
            // Logique pour ouvrir un menu de filtres plus avancé
          },
        ),
      ],
    );
  }

  Widget _buildHeaderImage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // support SVG asset header, raster asset, or network image
              if (widget.headerImage.toLowerCase().endsWith('.svg'))
                Positioned.fill(
                  child: SvgPicture.asset(
                    widget.headerImage,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                )
              else if (widget.headerImage.startsWith('http'))
                Positioned.fill(
                  child: Image.network(widget.headerImage, fit: BoxFit.cover),
                )
              else
                Positioned.fill(
                  child: Image.asset(widget.headerImage, fit: BoxFit.cover),
                ),
              // gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                 if(selected) _filterProducts(filter);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.deepOrange.shade100,
              labelStyle: TextStyle(
                color: _selectedFilter == filter ? Colors.deepOrange : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade200)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildProductCard(_filteredProducts[index]);
          },
          childCount: _filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    product['image'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Bouton Favori
                IconButton(
                  icon: Icon(
                    product['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                    color: product['isFavorite'] ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _toggleFavorite(product['id']),
                ),
                // Bouton Ajouter
                 Positioned(
                  bottom: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.deepOrange),
                      onPressed: () {},
                    ),
                  ),
                ),
                // Tag Indisponible
                if (!product['isAvailable'])
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text('Indisponible', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('(${product['weight']})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${product['price'].toStringAsFixed(0)} fcfa', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📍 ${product['location']}',
                    style: TextStyle(color: Colors.orange.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Note: this page intentionally does not provide a BottomNavigationBar so
  // the MainScreen's BottomNavigationBar remains the single source of truth.
}
