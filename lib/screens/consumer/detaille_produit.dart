import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/screens/auth/login_screen.dart';
import 'package:suguconnect_mobile/screens/consumer/chat_page_simple.dart';
import 'package:suguconnect_mobile/screens/consumer/payment_page.dart';
import 'dart:async';

// La page de détails du produit
class ProductDetailsPage extends StatefulWidget {
  final Map<String, String>? product;

  const ProductDetailsPage({super.key, this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  late double _price;
  bool _isFavorite = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Liste d'images pour le carrousel
  late List<String> _productImages;

  @override
  void initState() {
    super.initState();

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

      _productImages = [
        widget.product!['image']!,
        'https://placehold.co/600x400/FFA726/FFFFFF?text=${widget.product!['name']}+2',
        'https://placehold.co/600x400/FB8C00/FFFFFF?text=${widget.product!['name']}+3',
      ];
    } else {
      _price = 40000.0;
      _productImages = [
        'https://placehold.co/600x400/FFA726/FFFFFF?text=Orange+1',
        'https://placehold.co/600x400/FB8C00/FFFFFF?text=Orange+2',
        'https://placehold.co/600x400/F57C00/FFFFFF?text=Orange+3',
      ];
    }

    // Changement automatique des images (optionnel)
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateQuantity(int change) {
    setState(() {
      if (_quantity + change > 0) {
        _quantity += change;
      }
    });
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
                child: _productImages[index].startsWith('http')
                    ? Image.network(
                        _productImages[index],
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        _productImages[index],
                        fit: BoxFit.cover,
                      ),
              );
            },
          ),
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
