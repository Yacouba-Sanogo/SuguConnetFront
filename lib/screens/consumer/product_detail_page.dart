import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, String> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name'] ?? 'Détail produit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product['image'] != null) Image.asset(product['image']!),
            const SizedBox(height: 12),
            Text(product['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product['weight'] ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(product['price'] ?? '', style: const TextStyle(fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(product['location'] ?? ''),
          ],
        ),
      ),
    );
  }
}
