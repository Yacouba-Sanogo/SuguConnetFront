import 'package:flutter/material.dart';
import 'dart:ui';

// La page du panier
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Données fictives pour le panier
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': 1,
      'name': 'Choux',
      'producer': 'Ali Touré',
      'price': 30000.0,
      'image': 'https://placehold.co/100x100/E8F5E9/333?text=Choux',
      'quantity': 1,
      'isSelected': false,
    },
    {
      'id': 2,
      'name': 'Mangues',
      'producer': 'Ali Touré',
      'price': 30000.0,
      'image': 'https://placehold.co/100x100/C8E6C9/333?text=Mangues',
      'quantity': 6,
      'isSelected': false,
    },
    {
      'id': 3,
      'name': 'Tomates',
      'producer': 'Ali Touré',
      'price': 30000.0,
      'image': 'https://placehold.co/100x100/FFCDD2/333?text=Tomates',
      'quantity': 7,
      'isSelected': false,
    },
    {
      'id': 4,
      'name': 'Gombo', // Corrigé par rapport à l'image
      'producer': 'Ali Touré',
      'price': 30000.0,
      'image': 'https://placehold.co/100x100/A5D6A7/333?text=Gombo',
      'quantity': 2,
      'isSelected': true,
    }
  ];

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
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Construit la barre d'application (similaire à la page des favoris)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F9),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: const Icon(Icons.store, color: Colors.deepOrange),
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black54, size: 28),
              onPressed: () {},
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

  // Construit le corps de la page
  Widget _buildBody() {
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
        const SizedBox(height: 80), // Espace pour la barre de navigation
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
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSelection(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item['isSelected'] ? Colors.deepOrange : Colors.transparent,
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
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Producteur : ${item['producer']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${item['price'].toStringAsFixed(0)} fcfa', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        _buildQuantityButton(Icons.add, () => _updateQuantity(index, 1), isAdd: true),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed, {bool isAdd = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAdd ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isAdd ? Colors.white : Colors.black54, size: 16),
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
              const Text('Total : ', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                '${_calculateTotal().toStringAsFixed(0)} fcfa',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Widget pour le bouton "Acheter"
  Widget _buildCheckoutButton() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
                'Acheter',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
        ),
      );
  }

  // Construit la barre de navigation (identique)
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Accueil', false),
            _buildNavItem(Icons.favorite, 'Favoris', false),
            const SizedBox(width: 40),
            _buildNavItem(Icons.list_alt, 'Commandes', false),
            _buildNavItem(Icons.person, 'Profil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final color = isSelected ? Colors.red : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
