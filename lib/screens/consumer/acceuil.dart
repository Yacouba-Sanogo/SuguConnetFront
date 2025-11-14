import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'fruit_page.dart';
import 'notifications_page.dart';
import 'detaille_produit.dart';
import '../../models/produit_populaire.dart';
import '../../services/produit_populaire_service.dart';
import '../../services/api_service.dart';

// Page d'accueil principale de l'application consommateur
class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  late ProduitPopulaireService _produitPopulaireService;
  late ApiService _apiService;
  List<ProduitPopulaire> _produitsPopulaires = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _produitPopulaireService = ProduitPopulaireService(_apiService);
    _loadProduitsPopulaires();
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
      // Barre d'application avec logo et notifications
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png',
            height: 40), // Logo de l'application
        centerTitle: true, // Centrer le titre
        backgroundColor: Colors.white, // Fond blanc
        elevation: 0, // Pas d'ombre
        actions: [
          // Bouton de notification avec badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () {
                  // Navigation vers la page des notifications
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(),
                    ),
                  );
                },
              ),
              // Badge de notification (point orange)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.orange, // Couleur du badge
                    shape: BoxShape.circle, // Forme circulaire
                  ),
                  constraints: BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                  child: Text(
                    '3', // Nombre de notifications
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // Bouton de profil utilisateur
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              // Afficher un message temporaire pour le profil
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Page de profil à venir')),
              );
            },
          ),
        ],
      ),
      // Corps de la page avec défilement vertical
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
          children: [
            // Section image principale avec texte en overlay
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Marges latérales
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Coins arrondis
                child: Stack(
                  children: [
                    // Image de fond de la page d'accueil
                    SizedBox(
                      width: double.infinity, // Largeur complète
                      height: 200, // Hauteur fixe
                      child: Image.asset(
                        'assets/images/imagedelapagecusumerhome.png',
                        fit: BoxFit.cover, // Couvrir tout l'espace
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Découvrez nos produits frais',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

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

            // Grille de catégories
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCategoryCard(
                    context,
                    'Fruits',
                    // use the SVGs that exist under assets/images in this project
                    'assets/images/Fruits.svg',
                    'assets/images/pommes.png',
                    Colors.deepOrange,
                  ),
                  _buildCategoryCard(
                    context,
                    'Céréales',
                    'assets/images/Cereales.svg',
                    'assets/images/mais.png',
                    Colors.deepOrange,
                  ),
                  _buildCategoryCard(
                    context,
                    'Légumes',
                    'assets/images/Legumes.svg',
                    'assets/images/carottes.png',
                    Colors.deepOrange,
                  ),
                  _buildCategoryCard(
                    context,
                    'Épices',
                    'assets/images/Epices.svg',
                    'assets/images/Oignons.png',
                    Colors.deepOrange,
                  ),
                ],
              ),
            ),

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
      String headerImage, Color color) {
    return GestureDetector(
      onTap: () {
        // Navigate to the shared category page with different title and header image
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FruitPage(title: title, headerImage: headerImage),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FutureBuilder<bool>(
                  future: _assetExists(iconPath),
                  builder: (context, snapshot) {
                    final exists = snapshot.data ?? false;
                    if (iconPath.toLowerCase().endsWith('.svg') && exists) {
                      return SvgPicture.asset(
                        iconPath,
                        width: 34,
                        height: 34,
                        color: color,
                      );
                    }
                    // fallback to headerImage (raster) or to a placeholder
                    if (headerImage.isNotEmpty) {
                      return Image.asset(
                        headerImage,
                        width: 34,
                        height: 34,
                        color: color,
                        fit: BoxFit.contain,
                      );
                    }
                    return Icon(Icons.image, color: color, size: 34);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
