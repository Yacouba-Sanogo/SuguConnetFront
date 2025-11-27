import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/screens/auth/login_screen.dart';
import 'package:suguconnect_mobile/screens/consumer/chat_page.dart';
import 'package:suguconnect_mobile/screens/consumer/payment_page.dart';
import 'package:suguconnect_mobile/services/api_service.dart';
import 'package:suguconnect_mobile/services/produit_detail_service.dart';
import 'package:suguconnect_mobile/models/produit_detail.dart';
import 'package:dio/dio.dart';
import 'dart:async';

// La page de détails du produit
class ProductDetailsPage extends StatefulWidget {
  final Map<String, String>? product;
  final int? productId; // ID du produit pour charger depuis le backend

  const ProductDetailsPage({super.key, this.product, this.productId});

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
  final ProduitDetailService _produitDetailService = ProduitDetailService();

  // Animation pour l'image unique
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Liste d'images pour le carrousel
  late List<String> _productImages;
  bool _imagesLoading = true;
  bool _isLoading = false;
  ProduitDetail? _produitDetail;
  String? _errorMessage;

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

    // Charger depuis le backend si productId est fourni directement ou depuis widget.product
    if (widget.productId != null) {
      _loadProductFromBackend();
    } else if (widget.product != null) {
      // Essayer d'extraire l'ID du produit depuis le Map et charger depuis le backend
      final productIdStr = widget.product!['id'];
      if (productIdStr != null) {
        final productId = int.tryParse(productIdStr.toString());
        if (productId != null && productId > 0) {
          // Charger depuis le backend avec l'ID extrait
          _loadProductFromBackendWithId(productId);
        } else {
          // Utiliser les données du produit passées en paramètre (ancienne méthode)
          _loadProductFromMap();
        }
      } else {
        // Utiliser les données du produit passées en paramètre (ancienne méthode)
        _loadProductFromMap();
      }
    } else {
      _price = 40000.0;
      _imagesLoading = false;
      _productImages = [
        'https://placehold.co/600x400/FFA726/FFFFFF?text=Orange+1',
      ];
    }

    // Démarrer le timer seulement si nous avons plus d'une image
    _startAutoSlide();
  }

  // Charger le produit depuis le backend avec l'ID du widget
  Future<void> _loadProductFromBackend() async {
    if (widget.productId == null) return;
    await _loadProductFromBackendWithId(widget.productId!);
  }

  // Charger le produit depuis le backend avec un ID spécifique
  Future<void> _loadProductFromBackendWithId(int productId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imagesLoading = true;
    });

    try {
      final produitDetail = await _produitDetailService.getProduitDetailById(productId);
      
      // Log pour déboguer
      print('=== Produit chargé depuis le backend ===');
      print('Product ID: ${produitDetail.id}');
      print('Producteur ID: ${produitDetail.producteurId}');
      print('Nom producteur: ${produitDetail.nomProducteur}');
      print('Prénom producteur: ${produitDetail.prenomProducteur}');
      print('Localisation: ${produitDetail.localisationProducteur}');
      
      // Vérifier que le producteur est valide
      if (produitDetail.producteurId <= 0) {
        print('⚠️ ATTENTION: Producteur ID invalide (${produitDetail.producteurId})');
      }
      if (produitDetail.nomProducteur.isEmpty && produitDetail.prenomProducteur.isEmpty) {
        print('⚠️ ATTENTION: Nom et prénom du producteur vides');
      }
      
      // Construire les images depuis les photos du produit
      List<String> images = [];
      if (produitDetail.photos.isNotEmpty) {
        for (var photo in produitDetail.photos) {
          try {
            final imageUrl = await _apiService.buildImageUrl(photo);
            images.add(imageUrl);
          } catch (e) {
            print('Erreur lors de la construction de l\'URL de l\'image: $e');
          }
        }
      }
      
      if (images.isEmpty) {
        images = ['assets/images/pommes.png'];
      }
      
      setState(() {
        _produitDetail = produitDetail;
        _price = produitDetail.prixUnitaire;
        _productImages = images;
        _isLoading = false;
        _imagesLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement du produit depuis le backend: $e');
      // Si on a des données dans widget.product, les utiliser comme fallback
      if (widget.product != null) {
        print('Utilisation des données du Map comme fallback');
        _loadProductFromMap();
      } else {
        setState(() {
          _errorMessage = 'Erreur de chargement: $e';
          _isLoading = false;
          _imagesLoading = false;
          _productImages = ['assets/images/pommes.png'];
        });
      }
    }
  }

  // Charger le produit depuis le Map (ancienne méthode)
  void _loadProductFromMap() {
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

      setState(() {
        _productImages = images;
        _imagesLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la construction des URLs d\'images: $e');
      // En cas d'erreur, utiliser des placeholders
      setState(() {
        _productImages = [
          'https://placehold.co/600x400/FFA726/FFFFFF?text=${widget.product!['name']}+1',
        ];
        _imagesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateQuantity(int change) {
    setState(() {
      final newQuantity = _quantity + change;
      if (newQuantity > 0) {
        // Limiter la quantité au stock disponible si le produit est chargé depuis le backend
        if (_produitDetail != null && newQuantity > _produitDetail!.stockDisponible) {
          _quantity = _produitDetail!.stockDisponible;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stock disponible: ${_produitDetail!.stockDisponible}'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          _quantity = newQuantity;
        }
      }
    });
  }

  Widget _buildImageSlider() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: _imagesLoading
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : (_productImages.length == 1
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _productImages[0],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image,
                              size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _productImages.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _productImages[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image,
                                  size: 50, color: Colors.grey),
                            );
                          },
                        ),
                      );
                    },
                  )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.productId != null) {
                    _loadProductFromBackend();
                  }
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _buildProducerInfo(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceInfo(),
                  const SizedBox(height: 16),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 16),
                  _buildQuantitySelector(),
                  const SizedBox(height: 8),
                  _buildTotalPrice(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 20), // Espace pour le bouton fixe en bas
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: _buildAddToCartButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Details produit',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProductHeader() {
    final productName = _produitDetail?.nom ?? widget.product?['name'] ?? 'Poires du Maroc';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            productName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.grey.shade400,
            size: 28,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProducerInfo() {
    // Construire le nom du producteur
    String producerName;
    if (_produitDetail != null) {
      final nom = _produitDetail!.nomProducteur.trim();
      final prenom = _produitDetail!.prenomProducteur.trim();
      if (nom.isNotEmpty || prenom.isNotEmpty) {
        producerName = '$prenom $nom'.trim();
      } else {
        producerName = 'Producteur';
      }
    } else {
      producerName = widget.product?['producerName'] ?? 'Producteur';
    }
    
    final producerAvatar = widget.product?['producerAvatar'] ?? 'assets/images/improfil.png';
    
    // Construire la localisation
    String producerLocation;
    if (_produitDetail != null && _produitDetail!.localisationProducteur.isNotEmpty) {
      producerLocation = _produitDetail!.localisationProducteur;
    } else {
      producerLocation = widget.product?['location'] ?? 'Local';
    }
    
    final farmName = 'Djoliba'; // Vous pouvez ajouter ce champ au produit si nécessaire

    ImageProvider avatarProvider;
    if (producerAvatar.startsWith('http')) {
      avatarProvider = NetworkImage(producerAvatar);
    } else {
      avatarProvider = AssetImage(producerAvatar);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: avatarProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producteur : $producerName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ferme : $farmName, $producerLocation',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Producteur local, 100% bio et équitable.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '100% naturelle, sans engrais chimiques',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Prix : ${_produitDetail?.prixFormate ?? '${_price.toStringAsFixed(0)} fcfa'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_produitDetail?.unite != null)
                  _buildTag('Le ${_produitDetail!.unite.toLowerCase()}', Colors.orange.shade100, Colors.orange.shade700),
                if (_produitDetail?.unite == null && widget.product != null)
                  _buildTag('Le carton', Colors.orange.shade100, Colors.orange.shade700),
                const SizedBox(height: 8),
                _buildTag(
                  _produitDetail?.enStock == true || (_produitDetail == null && widget.product != null)
                      ? 'Disponible' 
                      : 'Indisponible',
                  (_produitDetail?.enStock == true || (_produitDetail == null && widget.product != null))
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  (_produitDetail?.enStock == true || (_produitDetail == null && widget.product != null))
                      ? Colors.green.shade700 
                      : Colors.red.shade700,
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quantité',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () => _updateQuantity(-1),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text('$_quantity',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _updateQuantity(1),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTotalPrice() {
    return Row(
      children: [
        const Text(
          'Prix total :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '${(_price * _quantity).toStringAsFixed(0)} fcfa',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        )
      ],
    );
  }

  Widget _buildDescription() {
    final description = _produitDetail?.description ?? 
                        widget.product?['description'] ?? 
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    // Vérifier si le produit est en stock (par défaut on assume qu'il est disponible)
    final bool enStock = true; // Vous pouvez ajuster cette logique selon vos besoins
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 0.0),
        child: Row(
        children: [
          // Bouton circulaire Menu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black87, size: 20),
              onPressed: () => _showOptionsMenu(context),
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Ajouter au panier
          Expanded(
            flex: 1,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFB662F),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: enStock ? () => _addToCart(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB662F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  enStock ? 'Ajouter au panier' : 'Rupture de stock',
                  style: const TextStyle(
                    fontFamily : "inter",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // Fonction pour afficher le menu d'options
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option 1: Discuter avec le producteur
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
                title: const Text(
                  'Discuter avec le producteur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  
                  // Extraire le producerId correctement
                  int? producerId;
                  print('=== Débogage extraction producerId (menu) ===');
                  print('_produitDetail est null: ${_produitDetail == null}');
                  if (_produitDetail != null) {
                    print('ProducteurId depuis ProduitDetail: ${_produitDetail!.producteurId}');
                    producerId = _produitDetail!.producteurId > 0 ? _produitDetail!.producteurId : null;
                  } else if (widget.product != null) {
                    print('Données widget.product: ${widget.product}');
                    print('Clés disponibles: ${widget.product!.keys.toList()}');
                    final producerIdStr = widget.product!['producerId'] ?? widget.product!['producteurId'];
                    print('producerIdStr depuis Map: $producerIdStr');
                    producerId = producerIdStr != null ? int.tryParse(producerIdStr.toString()) : null;
                    
                    // Si le producerId n'est pas dans le Map, essayer de charger depuis le backend
                    if (producerId == null || producerId <= 0) {
                      final productIdStr = widget.product!['id'];
                      if (productIdStr != null) {
                        final productId = int.tryParse(productIdStr.toString());
                        if (productId != null && productId > 0) {
                          print('Tentative de chargement depuis le backend avec productId: $productId');
                          // Charger depuis le backend de manière synchrone (afficher un loader)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chargement des informations du producteur...'),
                              backgroundColor: Colors.blue,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _loadProductFromBackendWithId(productId).then((_) {
                            // Réessayer après le chargement
                            if (mounted && _produitDetail != null && _produitDetail!.producteurId > 0) {
                              final producerName = _produitDetail!.producteurFullName;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    producerId: _produitDetail!.producteurId,
                                    producerName: producerName,
                                    producerAvatar: widget.product?['producerAvatar'] ??
                                        'assets/images/improfil.png',
                                  ),
                                ),
                              );
                            }
                          });
                          return;
                        }
                      }
                    }
                  }
                  
                  print('producerId final: $producerId');
                  
                  if (producerId == null || producerId <= 0) {
                    // Afficher une erreur si le producerId est invalide
                    print('❌ ERREUR: Producteur ID invalide - producerId: $producerId');
                    print('   ProduitDetail: ${_produitDetail?.id}');
                    print('   ProducteurId depuis ProduitDetail: ${_produitDetail?.producteurId}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Impossible de contacter le producteur. ${_produitDetail != null ? "Le producteur n\'est pas associé à ce produit." : "Les informations du producteur ne sont pas disponibles."}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                    return;
                  }
                  
                  // À ce point, producerId est garanti non-null et > 0
                  final validProducerId = producerId!;
                  
                  // Construire le nom du producteur
                  String producerName;
                  if (_produitDetail != null) {
                    final nom = _produitDetail!.nomProducteur.trim();
                    final prenom = _produitDetail!.prenomProducteur.trim();
                    if (nom.isNotEmpty || prenom.isNotEmpty) {
                      producerName = '$prenom $nom'.trim();
                    } else {
                      producerName = 'Producteur';
                    }
                  } else {
                    producerName = widget.product?['producerName'] ?? 'Producteur';
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        producerId: validProducerId,
                        producerName: producerName,
                        producerAvatar: widget.product?['producerAvatar'] ??
                            'assets/images/improfil.png',
                      ),
                    ),
                  );
                },
              ),
              // Option 2: Acheter
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.black87),
                title: const Text(
                  'Acheter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  if (!authProvider.isAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen(role: null)),
                    );
                    return;
                  }
                  _placeDirectOrder();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fonction pour ajouter au panier
  void _addToCart(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter pour ajouter au panier'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Récupérer l'ID du produit
      final productId = _produitDetail?.id ?? 
                       (widget.product?['id'] != null ? int.tryParse(widget.product!['id']!) : null);
      if (productId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: ID du produit introuvable'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Ajouter le produit au panier avec la quantité sélectionnée
      final response = await _apiService.post(
        '/consommateur/$userId/panier/ajouter/$productId',
        queryParameters: {'quantite': _quantity},
      );

      print('Réponse d\'ajout au panier: ${response.statusCode} - ${response.data}');
      if (response.statusCode == 200) {
        if (mounted) {
          final productName = _produitDetail?.nom ?? widget.product?['name'] ?? 'Produit';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$productName ajouté au panier'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Erreur lors de l\'ajout au panier: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget pour le bouton de chat avec le producteur
  Widget _buildChatButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          // Extraire le producerId correctement
          int? producerId;
          print('=== Débogage extraction producerId ===');
          print('_produitDetail est null: ${_produitDetail == null}');
          if (_produitDetail != null) {
            print('ProducteurId depuis ProduitDetail: ${_produitDetail!.producteurId}');
            producerId = _produitDetail!.producteurId > 0 ? _produitDetail!.producteurId : null;
          } else if (widget.product != null) {
            print('Données widget.product: ${widget.product}');
            print('Clés disponibles: ${widget.product!.keys.toList()}');
            final producerIdStr = widget.product!['producerId'] ?? widget.product!['producteurId'];
            print('producerIdStr depuis Map: $producerIdStr');
            producerId = producerIdStr != null ? int.tryParse(producerIdStr.toString()) : null;
            
            // Si le producerId n'est pas dans le Map, essayer de charger depuis le backend
            if (producerId == null || producerId <= 0) {
              final productIdStr = widget.product!['id'];
              if (productIdStr != null) {
                final productId = int.tryParse(productIdStr.toString());
                if (productId != null && productId > 0) {
                  print('Tentative de chargement depuis le backend avec productId: $productId');
                  // Charger depuis le backend de manière synchrone (afficher un loader)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chargement des informations du producteur...'),
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  _loadProductFromBackendWithId(productId).then((_) {
                    // Réessayer après le chargement
                    if (mounted && _produitDetail != null && _produitDetail!.producteurId > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            producerId: _produitDetail!.producteurId,
                            producerName: _produitDetail!.producteurFullName,
                            producerAvatar: widget.product!['producerAvatar'] ??
                                'assets/images/improfil.png',
                          ),
                        ),
                      );
                    }
                  });
                  return;
                }
              }
            }
          }
          
          print('producerId final: $producerId');
          
          if (producerId == null || producerId <= 0) {
            // Afficher une erreur si le producerId est invalide
            print('❌ ERREUR: Producteur ID invalide - producerId: $producerId');
            print('   ProduitDetail: ${_produitDetail?.id}');
            print('   ProducteurId depuis ProduitDetail: ${_produitDetail?.producteurId}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Impossible de contacter le producteur. ${_produitDetail != null ? "Le producteur n\'est pas associé à ce produit." : "Les informations du producteur ne sont pas disponibles."}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }
          
          // À ce point, producerId est garanti non-null et > 0
          final validProducerId = producerId!;
          
          // Construire le nom du producteur
          String producerName;
          if (_produitDetail != null) {
            final nom = _produitDetail!.nomProducteur.trim();
            final prenom = _produitDetail!.prenomProducteur.trim();
            if (nom.isNotEmpty || prenom.isNotEmpty) {
              producerName = '$prenom $nom'.trim();
            } else {
              producerName = 'Producteur';
            }
          } else {
            producerName = widget.product!['producerName'] ?? 'Producteur';
          }
          
          // Navigation vers la page de chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                producerId: validProducerId,
                producerName: producerName,
                producerAvatar: widget.product!['producerAvatar'] ??
                    'assets/images/improfil.png',
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'Contacter le producteur',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFB662F),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Fonction pour passer une commande directe
  void _placeDirectOrder() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderService = OrderService();

      // Afficher les informations de débogage
      print('Consumer ID: ${authProvider.currentUser?.id}');
      print('Product data: ${widget.product}');
      print('Product ID: ${widget.product?['id']}');
      print('Quantity: $_quantity');
      print('Price: $_price');
      print('Token: ${authProvider.token}');

      // Vérifier si l'utilisateur est authentifié
      if (authProvider.currentUser?.id == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Vérifier que les données du produit sont valides
      if (widget.product == null || widget.product?['id'] == null) {
        throw Exception('Données du produit invalides');
      }

      // Préparer les données de la commande
      final products = [
        {
          'produitId': widget.product!['id'],
          'quantite': _quantity,
        }
      ];

      print('Products data to send: $products');

      // Passer la commande
      final orderData = await orderService.placeDirectOrder(
        consumerId: authProvider.currentUser!.id!,
        products: products,
        paymentMethod: 'ORANGE_MONEY',
      );

      // Afficher les données de réponse pour le débogage
      print('Order response data: $orderData');

      // Calculer le montant en s'assurant que nous travaillons avec des nombres
      final priceValue =
          _price is double ? _price : double.tryParse(_price.toString()) ?? 0.0;
      final amount = priceValue * _quantity;

      // Préparer les données pour la page de paiement avec des conversions sécurisées
      final paymentOrderData = {
        'orderId': int.tryParse(orderData['idCommande'].toString()) ?? 1,
        'productId': widget.product!['id'],
        'productName': widget.product!['name'] ?? 'Produit',
        'quantity': _quantity,
        'amount': amount.toStringAsFixed(0),
        'consumerId': authProvider.currentUser!.id!,
        // Ajouter les éléments de la commande
        'items': [
          {
            'name': widget.product!['name'] ?? 'Produit',
            'price': _price,
            'quantity': _quantity,
            'productId': widget.product!['id'],
            'image': widget.product!['image'] ?? '', // Ajouter l'URL de l'image
          }
        ],
      };

      // Afficher les données de paiement pour le débogage
      print('Payment order data: $paymentOrderData');
      print('Order ID type: ${paymentOrderData['orderId'].runtimeType}');
      print('Amount type: ${paymentOrderData['amount'].runtimeType}');

      // Rediriger vers la page de paiement avec les données de la commande
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(orderData: paymentOrderData),
        ),
      );
    } catch (e) {
      // Afficher un message d'erreur
      print('Erreur lors de la redirection vers le paiement: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la redirection vers le paiement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
