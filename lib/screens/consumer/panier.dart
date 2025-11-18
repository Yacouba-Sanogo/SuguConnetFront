import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'notifications_page.dart';
import 'payment_page.dart';
import 'dart:ui';

// La page du panier
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiService _apiService = ApiService();

  // Contenu du panier côté mobile (rempli depuis le backend)
  List<Map<String, dynamic>> _cartItems = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Calcule le total des articles sélectionnés
  double _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      if (item['isSelected']) {
        total += item['price'] * item['quantity'];
      }
    }
    return total;
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      if (_cartItems[index]['quantity'] + change > 0) {
        _cartItems[index]['quantity'] += change;
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      _cartItems[index]['isSelected'] = !_cartItems[index]['isSelected'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  // Construit la barre d'application (similaire à la page des favoris)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFB662F)
          .withOpacity(0.3), // Couleur FB662F avec 30% d'opacité
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context).pop(),
          child: CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            child: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          ),
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.black54, size: 28),
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
            Container(
              margin: const EdgeInsets.only(top: 10, right: 12),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadCart() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId == null) {
        setState(() {
          _cartItems = [];
          _loading = false;
          _error = null;
        });
        return;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/consommateur/$userId/panier',
      );

      final data = response.data ?? {};

      // On s'attend à ce que le panier contienne une liste "panierProduits"
      final List<dynamic> panierProduits =
          (data['panierProduits'] as List?) ?? const [];

      final items = panierProduits.map<Map<String, dynamic>>((raw) {
        final pp = raw as Map<String, dynamic>;
        final produit = (pp['produit'] ?? {}) as Map<String, dynamic>;
        final producteur = (produit['producteur'] ?? {}) as Map<String, dynamic>;

        // Normaliser prix et quantite (peuvent arriver en String ou num)
        final dynamic rawPrix = pp['prixUnitaire'] ?? produit['prixUnitaire'] ?? 0;
        double price;
        if (rawPrix is num) {
          price = rawPrix.toDouble();
        } else {
          price = double.tryParse(rawPrix.toString()) ?? 0.0;
        }

        final dynamic rawQuantite = pp['quantite'] ?? 1;
        int quantity;
        if (rawQuantite is num) {
          quantity = rawQuantite.toInt();
        } else {
          quantity = int.tryParse(rawQuantite.toString()) ?? 1;
        }

        return <String, dynamic>{
          'id': produit['id'] ?? pp['id'] ?? 0,
          'name': produit['nom'] ?? 'Produit',
          'producer': producteur['nomEntreprise'] ??
              ((producteur['prenom'] ?? '') + ' ' + (producteur['nom'] ?? '')),
          'price': price,
          'image': produit['imageUrl'] ?? produit['image'] ?? '',
          'quantity': quantity,
          'isSelected': true,
        };
      }).toList();

      setState(() {
        _cartItems = items;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      // Si le backend renvoie 404 "Le panier est vide", on affiche simplement le panier vide
      setState(() {
        _cartItems = [];
        _loading = false;
        _error = null;
      });
    }
  }

  // Construit le corps de la page
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Votre panier est vide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index], index);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ),
        _buildTotalSection(),
        _buildCheckoutButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  // Widget pour un article du panier
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSelection(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    item['isSelected'] ? Colors.deepOrange : Colors.transparent,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: item['isSelected']
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['image'],
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Producteur : ${item['producer']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${(item['price'] as num).toDouble().toStringAsFixed(0)} fcfa',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildQuantityControl(index),
        ],
      ),
    );
  }

  // Widget pour le contrôle de la quantité
  Widget _buildQuantityControl(int index) {
    return Row(
      children: [
        _buildQuantityButton(Icons.remove, () => _updateQuantity(index, -1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _cartItems[index]['quantity'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _buildQuantityButton(Icons.add, () => _updateQuantity(index, 1),
            isAdd: true),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed,
      {bool isAdd = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAdd ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Icon(icon, color: isAdd ? Colors.white : Colors.black54, size: 16),
      ),
    );
  }

  // Widget pour la section du total
  Widget _buildTotalSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Total : ',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                '${_calculateTotal().toStringAsFixed(0)} fcfa',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour le bouton "Acheter"
  Widget _buildCheckoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Navigation vers la page de paiement
          print('Bouton de paiement cliqué'); // Debug

          // Préparer les données de commande
          final selectedItems =
              _cartItems.where((item) => item['isSelected']).toList();
          final orderData = {
            'orderId': 12345, // ID de commande fictif
            'amount': _calculateTotal(),
            'items': selectedItems.map((item) {
              return {
                'id': item['id'],
                'name': item['name'],
                'price': item['price'],
                'quantity': item['quantity'],
              };
            }).toList(),
          };

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(orderData: orderData),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFB662F), // Couleur FB662F
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Passer la commande',
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}
