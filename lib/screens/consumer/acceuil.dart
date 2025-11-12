import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'fruit_page.dart';
import 'notifications_page.dart';

// Page d'accueil principale de l'application consommateur
class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

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
        title: Image.asset('assets/images/logo.png', height: 40), // Logo de l'application
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
                      builder: (context) => const NotificationsPage(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Marges latérales
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
              child: Text(
                'Produits populaires',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Liste de produits populaires
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
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
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Center(
                            child: Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Produit ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '2,50 €',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 80), // Espace pour le FAB
          ],
        ),
      ),
     
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String iconPath, String headerImage, Color color) {
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

  Widget _buildBottomItem(BuildContext context, IconData icon, String label, bool active) {
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
