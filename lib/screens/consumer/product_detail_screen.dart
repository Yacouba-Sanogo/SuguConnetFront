import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/produit_detail.dart';
import '../../services/produit_detail_service.dart';
import '../../services/api_service.dart';
import 'chat_page_simple.dart';
import 'payment_page.dart'; // Import de la page de paiement

// La page de détails du produit avec intégration de l'API backend
class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProduitDetailService _produitDetailService;
  late ApiService _apiService;
  ProduitDetail? _produitDetail;
  bool _isLoading = true;
  String? _errorMessage;
  int _quantity = 1;
  bool _isFavorite = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _produitDetailService = ProduitDetailService();
    _apiService = ApiService();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final produitDetail =
          await _produitDetailService.getProduitDetailById(widget.productId);
      setState(() {
        _produitDetail = produitDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
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
      body: _buildBody(),
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadProductDetails,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_produitDetail == null) {
      return const Center(child: Text('Produit non trouvé'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSlider(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSlider() {
    if (_produitDetail == null || _produitDetail!.photos.isEmpty) {
      return SizedBox(
        height: 180,
        child: Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image, size: 50, color: Colors.grey),
        ),
      );
    }

    final photoUrls = _produitDetail!.photos;

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: photoUrls.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return FutureBuilder<String>(
                future: _apiService.getBaseUrl(),
                builder: (context, snapshot) {
                  final baseUrl = snapshot.data ?? 'http://10.0.2.2:8080';
                  final imageUrl = photoUrls[index];
                  final fullUrl = '$baseUrl/uploads/$imageUrl';

                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.cover,
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
              );
            },
          ),
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photoUrls.length, (index) {
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
        Expanded(
          child: Text(
            _produitDetail?.nom ?? 'Produit',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/improfil.png'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producteur : ${_produitDetail?.producteurFullName ?? 'Producteur'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                    'Localisation : ${_produitDetail?.localisationProducteur ?? 'Localisation'}',
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
                'Prix : ${_produitDetail?.prixFormate ?? '0 fcfa'}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildTag('${_produitDetail?.unite ?? ''}', Colors.pink.shade50,
                Colors.pink.shade400),
            const SizedBox(width: 8),
            _buildTag(
                _produitDetail?.enStock == true ? 'Disponible' : 'Indisponible',
                _produitDetail?.enStock == true
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                _produitDetail?.enStock == true
                    ? Colors.green.shade600
                    : Colors.red.shade600),
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
    final totalPrice = (_produitDetail?.prixUnitaire ?? 0) * _quantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Prix total :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          '${totalPrice.toStringAsFixed(0)} fcfa',
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
        Text(
          _produitDetail?.description ?? 'Aucune description disponible',
          style: const TextStyle(
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
                if (_produitDetail != null) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => ChatPageSimple(
                  //       producerName: _produitDetail!.producteurFullName,
                  //       producerAvatar: 'assets/images/improfil.png',
                  //     ),
                  //   ),
                  // );
                }
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
                // Rediriger vers la page de paiement avec les données du produit
                if (_produitDetail != null) {
                  final orderData = {
                    'orderId': _produitDetail!
                        .id, // Utiliser l'ID du produit comme ID de commande temporaire
                    'amount': (_produitDetail!.prixUnitaire * _quantity),
                    'items': [
                      {
                        'id': _produitDetail!.id,
                        'name': _produitDetail!.nom,
                        'price': _produitDetail!.prixUnitaire,
                        'quantity': _quantity,
                      }
                    ],
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentPage(orderData: orderData),
                    ),
                  );
                }
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
}
