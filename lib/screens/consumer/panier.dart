import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/order_service.dart'; // Ajout de l'import du service de commande
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
  final OrderService _orderService = OrderService();

  // Contenu du panier côté mobile (rempli depuis le backend)
  List<Map<String, dynamic>> _cartItems = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger le panier chaque fois que la page devient active
    _loadCart();
  }

  // Charge le contenu du panier depuis le backend
  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        setState(() {
          _loading = false;
          _error = 'Veuillez vous connecter';
        });
        return;
      }

      // Récupérer le panier depuis le backend
      final response = await _apiService.get('/consommateur/$userId/panier');

      if (response.statusCode == 200) {
        final data = response.data;
        final items = <Map<String, dynamic>>[];

        // Parcourir les éléments du panier
        if (data is List) {
          for (var item in data) {
            items.add({
              'id': item['produit']['id'].toString(),
              'name': item['produit']['nom'],
              'price': (item['produit']['prix'] as num).toDouble(),
              'quantity': item['quantite'] as int,
              'image': item['produit']['imageUrl'] ?? 'assets/images/improfil.png',
              'isSelected': true, // Par défaut, tous les articles sont sélectionnés
            });
          }
        }

        setState(() {
          _cartItems = items;
          _loading = false;
        });
      } else {
        throw Exception('Erreur lors du chargement du panier: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
      setState(() {
        _loading = false;
        _error = 'Erreur lors du chargement du panier';
      });
    }
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

  // Fonction pour mettre à jour la quantité d'un produit dans le panier
  void _updateQuantity(int index, int change) async {
    try {
      final item = _cartItems[index];
      final newQuantity = item['quantity'] + change;

      // Ne pas permettre une quantité négative ou nulle
      if (newQuantity <= 0) {
        // Retirer le produit du panier
        await _removeFromCart(index);
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Mettre à jour la quantité dans le backend
      final response = await _apiService.post(
        '/consommateur/$userId/panier/ajouter/${item['id']}',
        queryParameters: {'quantite': newQuantity},
      );

      if (response.statusCode == 200) {
        // Mettre à jour l'interface utilisateur
        setState(() {
          _cartItems[index]['quantity'] = newQuantity;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quantité mise à jour'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
            'Erreur lors de la mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la quantité: $e');
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

  // Fonction pour retirer un produit du panier
  Future<void> _removeFromCart(int index) async {
    try {
      final item = _cartItems[index];

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Retirer le produit du panier dans le backend
      final response = await _apiService.delete(
        '/consommateur/$userId/panier/retirer/${item['id']}',
      );

      if (response.statusCode == 200) {
        // Mettre à jour l'interface utilisateur
        setState(() {
          _cartItems.removeAt(index);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name']} retiré du panier'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Erreur lors du retrait: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors du retrait du produit: $e');
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

  // Fonction pour basculer la sélection d'un article
  void _toggleItemSelection(int index) {
    setState(() {
      _cartItems[index]['isSelected'] = !_cartItems[index]['isSelected'];
    });
  }

  // Fonction pour basculer la sélection de tous les articles
  void _toggleAllSelection(bool selectAll) {
    setState(() {
      for (var item in _cartItems) {
        item['isSelected'] = selectAll;
      }
    });
  }

  // Fonction pour passer une commande
  Future<void> _placeOrder() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Filtrer les articles sélectionnés
      final selectedItems = _cartItems.where((item) => item['isSelected']).toList();

      if (selectedItems.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner au moins un article'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Utiliser la méthode placeOrderFromCart du service de commande
      final response = await _orderService.placeOrderFromCart(
        consumerId: userId,
        paymentMethod: 'ORANGE_MONEY', // Mode de paiement par défaut
      );

      if (response.containsKey('id')) {
        // Vider le panier local
        setState(() {
          _cartItems.clear();
        });

        if (mounted) {
          // Naviguer vers la page de paiement
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                orderData: {
                  'amount': _calculateTotal(),
                  'items': selectedItems,
                },
              ),
            ),
          );
        }
      } else {
        throw Exception('Erreur lors de la commande');
      }
    } catch (e) {
      print('Erreur lors de la commande: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la commande: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Panier',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black54,
                    size: 24,
                  ),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _loadCart,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _cartItems.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartContent(),
    );
  }

  // Construit l'affichage du panier vide
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_cart.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          const Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ajoutez des produits à votre panier',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Construit le contenu du panier
  Widget _buildCartContent() {
    return Column(
      children: [
        _buildCartHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index], index);
            },
          ),
        ),
        _buildCartFooter(),
      ],
    );
  }

  // Construit l'en-tête du panier
  Widget _buildCartHeader() {
    final allSelected = _cartItems.every((item) => item['isSelected']);
    final selectedCount = _cartItems.where((item) => item['isSelected']).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleAllSelection(!allSelected),
            child: Row(
              children: [
                Icon(
                  allSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: const Color(0xFFFB662F),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tout sélectionner',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text('$selectedCount article(s) sélectionné(s)'),
        ],
      ),
    );
  }

  // Construit un élément du panier
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Case à cocher
          GestureDetector(
            onTap: () => _toggleItemSelection(index),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Icon(
                item['isSelected']
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: const Color(0xFFFB662F),
              ),
            ),
          ),
          // Image du produit
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(item['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Détails du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['price'].toStringAsFixed(2)} FCFA',
                  style: const TextStyle(
                    color: Color(0xFFFB662F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Contrôles de quantité
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _updateQuantity(index, -1),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item['quantity'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _updateQuantity(index, 1),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB662F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _removeFromCart(index),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construit le pied de page du panier
  Widget _buildCartFooter() {
    final total = _calculateTotal();
    final selectedCount = _cartItems.where((item) => item['isSelected']).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} FCFA',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFB662F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedCount > 0 ? _placeOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFB662F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Commander',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}