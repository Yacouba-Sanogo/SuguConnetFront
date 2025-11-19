import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/screens/auth/login_screen.dart';
import 'package:suguconnect_mobile/screens/consumer/chat_page.dart';
import 'package:suguconnect_mobile/screens/consumer/payment_page.dart';
import 'package:suguconnect_mobile/services/api_service.dart';
import 'package:dio/dio.dart';
import 'dart:async';

// La page de détails du produit
class ProductDetailsPage extends StatefulWidget {
  final Map<String, String>? product;

  const ProductDetailsPage({super.key, this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late double _price;
  bool _isFavorite = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();

  // Animation pour l'image unique
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Liste d'images pour le carrousel
  late List<String> _productImages;
  bool _imagesLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialisation de l'animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Répéter l'animation en boucle
    _animationController.repeat(reverse: true);

    // Initialisation avec des placeholders pendant le chargement
    _productImages = [
      'https://placehold.co/600x400/FFA726/FFFFFF?text=Chargement...',
    ];

    // Utiliser les données du produit ou des valeurs par défaut
    if (widget.product != null) {
      // Afficher les données du produit pour le débogage
      print('Product data in initState: ${widget.product}');

      // Extraire le prix et le convertir en nombre
      final priceString = widget.product!['price']?.toString() ?? '0';
      print('Price string: $priceString');

      // Nettoyer la chaîne de caractères pour ne garder que les chiffres
      final cleanedPriceString = priceString.replaceAll(RegExp(r'[^\d.]'), '');
      print('Cleaned price string: $cleanedPriceString');

      // Convertir en double
      _price = double.tryParse(cleanedPriceString) ?? 0.0;
      print('Parsed price: $_price');

      // Construire les URLs d'images
      _buildImageUrls();
    } else {
      _price = 40000.0;
      _imagesLoading = false; // Pas de chargement nécessaire
      _productImages = [
        'https://placehold.co/600x400/FFA726/FFFFFF?text=Orange+1',
      ];
    }

    // Démarrer le timer seulement si nous avons plus d'une image
    _startAutoSlide();
  }

  // Fonction pour démarrer le défilement automatique
  void _startAutoSlide() {
    // Ne pas démarrer le timer si nous n'avons qu'une seule image
    if (_productImages.length <= 1) return;

    // Changement automatique des images (optionnel)
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentPage < _productImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  // Fonction pour vérifier si une image existe
  Future<bool> _imageExists(String url) async {
    try {
      // Créer une requête HEAD manuellement en utilisant Dio
      final dio = Dio();
      final response = await dio.head(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la vérification de l\'image $url: $e');
      return false;
    }
  }

  // Fonction pour construire les URLs d'images
  void _buildImageUrls() async {
    try {
      final String? mainImage = widget.product!['image'];

      List<String> images = [];

      if (mainImage != null && mainImage.isNotEmpty) {
        // Utiliser le service API pour construire l'URL complète
        final String fullImageUrl = await _apiService.buildImageUrl(mainImage);
        images.add(fullImageUrl);
      } else {
        images.add(
            'https://placehold.co/600x400/FFA726/FFFFFF?text=${widget.product!['name']}+1');
      }

      // Générer des URLs potentielles pour des images supplémentaires
      // Par exemple, si l'image principale est "image123.jpg", on peut essayer "image123_2.jpg"
      if (mainImage != null && mainImage.isNotEmpty) {
        final String baseName = mainImage.split('.').first;
        final String extension = mainImage.split('.').last;

        // Vérifier l'existence d'images supplémentaires
        final potentialImages = [
          '${baseName}_2.$extension',
          '${baseName}_3.$extension',
          '${baseName}2.$extension',
        ];

        for (final potentialImage in potentialImages) {
          final fullUrl = await _apiService.buildImageUrl(potentialImage);
          if (await _imageExists(fullUrl)) {
            images.add(fullUrl);
          }
        }
      }

      // Si aucune image supplémentaire n'a été trouvée, ajouter des placeholders
      if (images.length == 1) {
        images.addAll([
          'https://placehold.co/600x400/FFA726/FFFFFF?text=${widget.product!['name']}+2',
          'https://placehold.co/600x400/FB8C00/FFFFFF?text=${widget.product!['name']}+3',
        ]);
      }

      setState(() {
        _productImages = images;
        _imagesLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des images: $e');
      // En cas d'erreur, utiliser des placeholders
      setState(() {
        _productImages = [
          'https://placehold.co/600x400/FFA726/FFFFFF?text=${widget.product!['name']}+1',
          'https://placehold.co/600x400/FFA726/FFFFFF?text=${widget.product!['name']}+2',
          'https://placehold.co/600x400/FB8C00/FFFFFF?text=${widget.product!['name']}+3',
        ];
        _imagesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Fonction pour incrémenter la quantité
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  // Fonction pour décrémenter la quantité
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Fonction pour ajouter au panier
  Future<void> _addToCart() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Vérifier si l'utilisateur est connecté
      if (!authProvider.isAuthenticated) {
        // Rediriger vers la page de connexion
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      // Obtenir l'ID de l'utilisateur
      final userId = authProvider.currentUser?.id;
      if (userId == null) {
        throw Exception('Impossible d\'obtenir l\'ID de l\'utilisateur');
      }

      // Obtenir l'ID du produit
      final productId = int.tryParse(widget.product?['id'] ?? '') ?? 0;
      if (productId == 0) {
        throw Exception('ID du produit invalide');
      }

      // Appeler le service pour ajouter au panier
      // Note: This needs to be implemented in OrderService
      // For now, we'll show a placeholder message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fonctionnalité d\'ajout au panier à implémenter'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout au panier: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour acheter maintenant
  void _buyNow() {
    // Créer les données de commande
    final orderData = {
      'amount': _price * _quantity,
      'items': [
        {
          'id': widget.product?['id'] ?? '',
          'name': widget.product?['name'] ?? 'Produit',
          'quantity': _quantity,
          'price': _price,
          'total': _price * _quantity,
        }
      ],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(orderData: orderData),
      ),
    );
  }

  // Fonction pour contacter le producteur
  void _contactProducer() {
    // Obtenir l'ID du producteur à partir des données du produit
    final producerId = int.tryParse(widget.product?['producerId'] ?? '0') ?? 0;
    final producerName = widget.product?['producerName'] ?? 'Producteur';
    final producerAvatar = widget.product?['producerAvatar'] ?? '';

    if (producerId > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            producerId: producerId,
            producerName: producerName,
            producerAvatar: producerAvatar,
          ),
        ),
      );
    } else {
      // Afficher un message d'erreur si l'ID du producteur n'est pas disponible
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de contacter le producteur pour le moment'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrousel d'images
            _buildImageCarousel(),

            // Informations du produit
            _buildProductInfo(),

            // Description du produit
            _buildProductDescription(),

            // Informations supplémentaires
            _buildAdditionalInfo(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Construire le carrousel d'images
  Widget _buildImageCarousel() {
    return Container(
      height: 300,
      color: Colors.grey[200],
      child: _imagesLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _productImages.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    );
                  },
                  child: Image.network(
                    _productImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://placehold.co/600x400/FFA726/FFFFFF?text=Image+non+disponible',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  // Construire les indicateurs de page
  Widget _buildPageIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_productImages.length, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 12 : 8,
            height: _currentPage == index ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? const Color(0xFFFF6B35)
                  : Colors.grey[300],
            ),
          );
        }),
      ),
    );
  }

  // Construire les informations du produit
  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom du produit
          Text(
            widget.product?['name'] ?? 'Orange de qualité supérieure',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Localisation et poids
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                widget.product?['location'] ?? 'Abidjan, Cocody',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.scale, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                widget.product?['weight'] ?? '1 kg',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Prix
          Row(
            children: [
              Text(
                '${_price.toStringAsFixed(0)} fcfa',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '50 000 fcfa',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quantité
          Row(
            children: [
              const Text(
                'Quantité:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decrementQuantity,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementQuantity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Construire la description du produit
  Widget _buildProductDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product?['description'] ??
                'Découvrez nos oranges de première qualité, cultivées dans les meilleures conditions. Ces oranges sont riches en vitamine C et parfaites pour une consommation fraîche ou pour la préparation de jus. Cueillies à la main par nos agriculteurs locaux, elles garantissent un goût exceptionnel et une fraîcheur optimale.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Construire les informations supplémentaires
  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations supplémentaires',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Producteur', widget.product?['producerName'] ?? 'M. Kouassi'),
          _buildInfoRow('Origine', 'Côte d\'Ivoire'),
          _buildInfoRow('Variété', 'Orange douce'),
          _buildInfoRow('Conditionnement', 'Filet de 1 kg'),
          _buildInfoRow('Disponibilité', 'En stock'),
          _buildInfoRow('Date de récolte', '15 Juin 2024'),
        ],
      ),
    );
  }

  // Construire une ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construire la barre du bas
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _contactProducer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFF6B35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Contacter',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _buyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Acheter maintenant',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}