import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/screens/auth/login_screen.dart';
import 'package:suguconnect_mobile/screens/consumer/chat_page_simple.dart';
import 'package:suguconnect_mobile/screens/consumer/payment_page.dart';
import 'package:suguconnect_mobile/services/api_service.dart';
import 'package:dio/dio.dart'; // Ajout de l'import Dio
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
          '${baseName}3.$extension',
        ];

        for (final potentialImage in potentialImages) {
          try {
            final fullUrl = await _apiService.buildImageUrl(potentialImage);
            if (await _imageExists(fullUrl)) {
              images.add(fullUrl);
            }
          } catch (e) {
            print(
                'Erreur lors de la vérification de l\'image $potentialImage: $e');
          }
        }
      }

      // Ajouter quelques placeholders si nous n'avons toujours qu'une seule image
      if (images.length == 1) {
        final String placeholder2 =
            'https://placehold.co/600x400/FB8C00/FFFFFF?text=${widget.product!['name']}+2';
        final String placeholder3 =
            'https://placehold.co/600x400/F57C00/FFFFFF?text=${widget.product!['name']}+3';
        images.add(placeholder2);
        images.add(placeholder3);
      }

      if (mounted) {
        setState(() {
          _productImages = images;
          _imagesLoading = false;
        });

        // Redémarrer le défilement automatique si nécessaire
        _startAutoSlide();
      }
    } catch (e) {
      print('Erreur lors de la construction des URLs d\'images: $e');
      // En cas d'erreur, utiliser une seule image
      if (mounted) {
        setState(() {
          _productImages = [
            'https://placehold.co/600x400/FFA726/FFFFFF?text=${widget.product!['name']}+1',
          ];
          _imagesLoading = false;
        });

        // Redémarrer le défilement automatique si nécessaire
        _startAutoSlide();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose(); // Dispose l'animation controller
    super.dispose();
  }

  Widget _buildImageSlider() {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _productImages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: _imagesLoading
                    ? Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : (_productImages.length == 1
                        // Animation pour l'image unique
                        ? ScaleTransition(
                            scale: _scaleAnimation,
                            child: Image.network(
                              _productImages[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Image de secours en cas d'erreur
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image,
                                      size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          )
                        // Pas d'animation pour plusieurs images
                        : Image.network(
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
                              // Image de secours en cas d'erreur
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image,
                                    size: 50, color: Colors.grey),
                              );
                            },
                          )),
              );
            },
          ),
          // Indicateur de pagination seulement si nous avons plus d'une image
          if (_productImages.length > 1)
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_productImages.length, (index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSlider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 12),
                  _buildProducerInfo(),
                  const SizedBox(height: 12),
                  _buildPriceInfo(),
                  const SizedBox(height: 16),
                  _buildQuantitySelector(),
                  const SizedBox(height: 8),
                  _buildTotalPrice(),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Détails produit',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  void _updateQuantity(int change) {
    setState(() {
      if (_quantity + change > 0) {
        _quantity += change;
      }
    });
  }

  Widget _buildProductHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.product?['name'] ?? 'Orange du Maroc',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.grey,
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
    final producerName = widget.product?['producerName'] ?? 'Sory Coulibaly';
    final producerAvatar =
        widget.product?['producerAvatar'] ?? 'assets/images/improfil.png';
    final producerLocation = widget.product?['location'] ?? 'Bamako';

    ImageProvider avatarProvider;
    if (producerAvatar.startsWith('http')) {
      avatarProvider = NetworkImage(producerAvatar);
    } else {
      avatarProvider = AssetImage(producerAvatar);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: avatarProvider,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producteur : $producerName',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text('Localisation : $producerLocation',
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 2),
                const Text('Producteur local, 100% bio et équitable.',
                    style: TextStyle(color: Colors.grey, fontSize: 10)),
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
          style: TextStyle(color: Colors.orange, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Prix : ${widget.product?['price'] ?? '${_price.toStringAsFixed(0)} fcfa'}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildTag(widget.product?['weight'] ?? '20 kg', Colors.pink.shade50,
                Colors.pink.shade400),
            const SizedBox(width: 8),
            _buildTag(
                'Disponible', Colors.green.shade50, Colors.green.shade600),
          ],
        )
      ],
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Prix total :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          '${(_price * _quantity).toStringAsFixed(0)} fcfa',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange),
        )
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Produit frais et naturel, cultivé localement sans engrais chimiques. Idéal pour une alimentation saine et équilibrée.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPageSimple(
                      producerName:
                          widget.product?['producerName'] ?? 'Producteur local',
                      producerAvatar: widget.product?['producerAvatar'] ??
                          'assets/images/improfil.png',
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFB662F),
                side: const BorderSide(color: Color(0xFFFB662F), width: 2),
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Discuter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Vérifier si l'utilisateur est authentifié
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                if (!authProvider.isAuthenticated) {
                  // Rediriger vers l'écran de connexion si l'utilisateur n'est pas authentifié
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                  return;
                }

                // Passer la commande directement
                _placeDirectOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB662F),
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Acheter',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
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
