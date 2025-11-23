import 'package:flutter/material.dart';

/// Widget réutilisable pour une carte d'article du panier
class CartItemCard extends StatelessWidget {
  final Widget image;
  final String name;
  final String price;
  final int quantity;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback? onRemove;
  final Widget? quantitySelector;

  const CartItemCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onDecrement,
    required this.onIncrement,
    this.onRemove,
    this.quantitySelector,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggleSelection,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.deepOrange : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.deepOrange : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: image,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (quantitySelector != null) quantitySelector!,
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}


