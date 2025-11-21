import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'fruit_page.dart';
import 'notifications_page.dart';
import 'detaille_produit.dart';
import '../../models/produit_populaire.dart';
import '../../services/produit_populaire_service.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart'; // Ajout du service produit
import '../../models/product.dart'; // Ajout du modèle produit
import 'category_products_page.dart'; // Ajout de la nouvelle page
import '../consumer/panier.dart';
import '../../widgets/entete_accueil.dart'; // Widget d'en-tête

// Page d'accueil principale de l'application consommateur
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  late ProduitPopulaireService _produitPopulaireService;
  late ApiService _apiService;
  late ProductService _productService; // Ajout du service produit
  List<ProduitPopulaire> _produitsPopulaires = [];
  List<Categorie> _categories = []; // Ajout de la liste des catégories
  bool _isLoading = true;
  bool _isLoadingCategories = true; // Ajout du chargement des catégories
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _productService = ProductService(); // Initialisation du service produit
    _produitPopulaireService = ProduitPopulaireService(_apiService);
    _loadProduitsPopulaires();
    _loadCategories(); // Chargement des catégories
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

  // Fonction pour charger les catégories depuis le backend
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
    
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Section image principale avec le widget d'en-tête
            const EnteteAccueil(),

            SizedBox(height: 20),

            // Titre de section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Découvrir par catégorie',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),

            SizedBox(height: 16),

            // Grille de catégories dynamiques
            _buildCategoriesSection(),

            SizedBox(height: 20),

            // Section produits populaires
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produits populaires',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  TextButton(
                    onPressed: _loadProduitsPopulaires,
                    child: Text('Actualiser'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Liste de produits populaires
            _buildPopularProductsSection(),

            SizedBox(height: 80), // Espace pour le FAB
          ],
        ),
      ),
    );
  }

  // Widget pour la section des catégories dynamiques
  Widget _buildCategoriesSection() {
    if (_isLoadingCategories) {
      return Container(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Mapping des catégories avec leurs icônes, images et couleurs
    final categoryData = {
      'Fruits': {
        'icon': 'assets/icons/fruits.png',
        'image': 'assets/images/fruits.jpg',
        'backgroundColor': Color(0x4DF97A00), // F97A00 à 30%
        'iconColor': Color(0xFFF97A00), // Orange pour l'icône
      },
      'Légumes': {
        'icon': 'assets/icons/legumes.png',
        'image': 'assets/images/legumes.jpg',
        'backgroundColor': Color(0x4D8FA31E),
        'iconColor': Color(0xFF8FA31E), // Vert pour l'icône
      },
      'Céréales': {
        'icon': 'assets/icons/cereales.png',
        'image': 'assets/images/cereales.jpg',
        'backgroundColor': Color(0x33FFFF00),
        'iconColor': Color(0xFFFFAA00), // Orange pour l'icône
      },
      
      'Épices': {
        'icon': 'assets/icons/epices.png',
        'image': 'assets/images/epices.jpg',
        'backgroundColor': Color(0x4CDC143C),
        'iconColor': Color(0xFFDC143C), // Rouge pour l'icône
      },
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: _categories.map((categorie) {
          final data = categoryData[categorie.nom] ??
              {
                'icon': 'assets/icons/fruits.png',
                'image': 'assets/images/pommes.png',
                'backgroundColor': Color(0x4DF97A00),
                'iconColor': Color(0xFFF97A00),
              };

          return _buildCategoryCard(
            context,
            categorie.nom,
            data['icon'] as String,
            data['image'] as String,
            data['iconColor'] as Color,
            data['backgroundColor'] as Color,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularProductsSection() {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadProduitsPopulaires,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_produitsPopulaires.isEmpty) {
      return Container(
        height: 200,
        child: Center(child: Text('Aucun produit populaire trouvé')),
      );
    }

    return FutureBuilder<String>(
      future: _apiService.getBaseUrl(),
      builder: (context, snapshot) {
        final baseUrl = snapshot.data ?? 'http://10.0.2.2:8080';
        return Container(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _produitsPopulaires.length,
            itemBuilder: (context, index) {
              final produit = _produitsPopulaires[index];

              // Créer une structure de données compatible avec ProductDetailsPage
              final productData = <String, String>{
                'id': produit.produitId.toString(),
                'name': produit.nomProduit,
                'price': '${produit.prixUnitaire.toStringAsFixed(0)} fcfa',
                'weight': '${produit.unite}',
                'location': 'Local',
                'image': produit.photoUrl,
                'producerName': produit.nomProducteur,
                'producerId': produit.producteurId
                    .toString(), // Ajout de l'ID du producteur
                'producerAvatar': 'assets/images/improfil.png',
                'description': produit.description,
              };

              return GestureDetector(
                onTap: () {
                  // Naviguer vers la page de détail du produit
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: productData),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Center(
                          child: produit.photoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: _buildProductImage(
                                      produit.photoUrl, baseUrl),
                                )
                              : Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produit.nomProduit,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${produit.prixUnitaire.toStringAsFixed(2)} FCFA',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${produit.unite}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductImage(String photoUrl, String baseUrl) {
    // Utiliser le service API pour construire l'URL de l'image
    return FutureBuilder<String>(
      future: _apiService.buildImageUrl(photoUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final fullUrl = snapshot.data!;
          return Image.network(
            fullUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey));
            },
          );
        } else {
          // En attendant, utiliser l'ancienne méthode
          if (photoUrl.startsWith('http://') ||
              photoUrl.startsWith('https://')) {
            return Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey));
              },
            );
          }

          // Sinon, construire l'URL complète
          final fullUrl = '$baseUrl/uploads/$photoUrl';
          return Image.network(
            fullUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey));
            },
          );
        }
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String iconPath,
      String headerImage, Color iconColor, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        // Trouver la catégorie correspondante
        final categorie = _categories.firstWhere(
          (cat) => cat.nom == title,
          orElse: () => Categorie(
            id: 0,
            nom: title,
            dateCreation: DateTime.now(),
          ),
        );

        // Navigate to the new category products page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryProductsPage(
              category: categorie,
              headerImage: headerImage,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<bool>(
              future: _assetExists(iconPath),
              builder: (context, snapshot) {
                final exists = snapshot.data ?? false;
                if (iconPath.toLowerCase().endsWith('.svg') && exists) {
                  return SvgPicture.asset(
                    iconPath,
                    width: 64,
                    height: 64,
                    color: iconColor,
                  );
                }
                // Pour les PNG, utiliser iconPath directement
                if (exists && iconPath.toLowerCase().endsWith('.png')) {
                  return Image.asset(
                    iconPath,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  );
                }
                // fallback to headerImage (raster) or to a placeholder
                if (headerImage.isNotEmpty) {
                  return Image.asset(
                    headerImage,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  );
                }
                return Icon(Icons.image, color: iconColor, size: 64);
              },
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(
      BuildContext context, IconData icon, String label, bool active) {
    final color = active ? Colors.orange : Colors.black54;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label - à implémenter')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
