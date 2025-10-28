import 'package:flutter/material.dart';
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
      _price = double.parse(widget.product!['price']!.replaceAll(RegExp(r'[^\d]'), ''));
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
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
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
            backgroundImage: NetworkImage('https://placehold.co/100x100/7CB342/FFFFFF?text=S.C'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Producteur : Sory Coulibaly',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text('Ferme : Djoliba, Koulikoro', style: TextStyle(color: Colors.grey, fontSize: 10)),
                SizedBox(height: 2),
                Text('Producteur local, 100% bio et équitable.', style: TextStyle(color: Colors.grey, fontSize: 10)),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildTag(widget.product?['weight'] ?? '20 kg', Colors.pink.shade50, Colors.pink.shade400),
            const SizedBox(width: 8),
            _buildTag('Disponible', Colors.green.shade50, Colors.green.shade600),
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
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quantité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        const Text('Prix total :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          '${(_price * _quantity).toStringAsFixed(0)} fcfa',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité de discussion à venir')),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produit ajouté au panier')),
                );
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
