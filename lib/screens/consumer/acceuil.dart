import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../models/produit_populaire.dart';
import '../../services/produit_populaire_service.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import 'category_products_page.dart';
import '../consumer/panier.dart';
import 'notifications_page.dart';

// Page d'accueil principale de l'application consommateur
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  late ProduitPopulaireService _produitPopulaireService;
  late ApiService _apiService;
  late ProductService _productService;
  List<ProduitPopulaire> _produitsPopulaires = [];
  List<Categorie> _categories = [];
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _productService = ProductService();
    _produitPopulaireService = ProduitPopulaireService(_apiService);
    _loadProduitsPopulaires();
    _loadCategories();
  }

  Future<void> _loadProduitsPopulaires() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final produits = await _produitPopulaireService.getProduitsPopulaires();
      setState(() {
        _produitsPopulaires = produits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _productService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      // En cas d'erreur, utiliser des catégories par défaut
      setState(() {
        _categories = [
          Categorie(
            id: 1,
            nom: 'Fruits',
            description: 'Fruits frais',
            dateCreation: DateTime.now(),
          ),
          Categorie(
            id: 2,
            nom: 'Légumes',
            description: 'Légumes frais',
            dateCreation: DateTime.now(),
          ),
          Categorie(
            id: 3,
            nom: 'Céréales',
            description: 'Céréales et grains',
            dateCreation: DateTime.now(),
          ),
          Categorie(
            id: 4,
            nom: 'Épices',
            description: 'Épices et condiments',
            dateCreation: DateTime.now(),
          ),
        ];
        _isLoadingCategories = false;
      });
    }
  }

  // Fonction utilitaire pour vérifier si un asset existe au runtime
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SuguConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 245, 140, 2)),
            onPressed: () {
              // Navigation vers la page de notifications
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      // Corps de la page avec défilement vertical
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière promotionnelle
            Container(
              height: 150,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Livraison gratuite dès 10 000 FCFA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commandez vos produits locaux',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section des catégories
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catégories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final categorie = _categories[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryProductsPage(
                                      category: categorie,
                                      headerImage: 'assets/images/logo.png',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    categorie.nom,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),

            // Section des produits populaires
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produits Populaires',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(
                              child: Column(
                                children: [
                                  Text(_errorMessage!),
                                  ElevatedButton(
                                    onPressed: _loadProduitsPopulaires,
                                    child: const Text('Réessayer'),
                                  ),
                                ],
                              ),
                            )
                          : _produitsPopulaires.isEmpty
                              ? const Center(
                                  child: Text('Aucun produit disponible'),
                                )
                              : CarouselSlider.builder(
                                  itemCount: _produitsPopulaires.length,
                                  itemBuilder: (context, index, realIndex) {
                                    final produit = _produitsPopulaires[index];
                                    return _ProduitPopulaireCard(produit: produit);
                                  },
                                  options: CarouselOptions(
                                    height: 200,
                                    autoPlay: true,
                                    enlargeCenterPage: true,
                                    aspectRatio: 16 / 9,
                                  ),
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

// Widget pour afficher une carte de produit populaire
class _ProduitPopulaireCard extends StatelessWidget {
  final ProduitPopulaire produit;

  const _ProduitPopulaireCard({required this.produit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: produit.photoUrl ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Nom du produit
            Text(
              produit.nomProduit,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Prix du produit
            Text(
              '${produit.prixUnitaire.toStringAsFixed(2)} FCFA',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}