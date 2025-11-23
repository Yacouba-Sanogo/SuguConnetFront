import 'package:flutter/material.dart';
import 'card_container.dart';
import 'status_badge.dart';

/// Widget réutilisable pour une carte de commande
class OrderCard extends StatelessWidget {
  final String orderId;
  final String client;
  final String status;
  final double total;
  final String date;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.client,
    required this.status,
    required this.total,
    required this.date,
    this.onTap,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CardContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande n°$orderId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (onView != null || onDelete != null)
                  Row(
                    children: [
                      if (onView != null)
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.grey),
                          onPressed: onView,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Client: $client',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: status),
                Text(
                  '${total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

