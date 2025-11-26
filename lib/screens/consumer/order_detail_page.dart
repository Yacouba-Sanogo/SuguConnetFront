import 'package:flutter/material.dart';
import '../../constantes.dart';
import '../../services/api_service.dart';

// Page de détail d'une commande spécifique
class OrderDetailPage extends StatelessWidget {
  final String orderId;
  final String client;
  final String status;
  final double total;
  final String date;
  final String? producerName;
  final String? productName;
  final String? productImage;
  final int? quantity;
  final double? unitPrice;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.client,
    required this.status,
    required this.total,
    required this.date,
    this.producerName,
    this.productName,
    this.productImage,
    this.quantity,
    this.unitPrice,
  });

  // Détermine l'étape actuelle basée sur le statut
  int _getCurrentStep() {
    final statusUpper = status.toUpperCase();
    if (statusUpper.contains('PAYE') || statusUpper.contains('PAYÉ')) {
      return 0; // Paiement
    }
    if (statusUpper.contains('EXPEDIE') || 
        statusUpper.contains('EXPÉDIÉ') || 
        statusUpper.contains('EN COURS') ||
        statusUpper.contains('EN_COURS')) {
      return 1; // Expédition
    }
    if (statusUpper.contains('LIVREE') || 
        statusUpper.contains('LIVRÉE') || 
        statusUpper.contains('RECU') ||
        statusUpper.contains('REÇU')) {
      return 2; // Réception
    }
    if (statusUpper.contains('NOTE') || 
        statusUpper.contains('EVALUE') || 
        statusUpper.contains('ÉVALUÉ')) {
      return 3; // Note
    }
    // Par défaut, on considère que le paiement est fait
    return 1; // Expédition par défaut
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _getCurrentStep();
    final steps = ['Paiement', 'Expédition', 'Réception', 'Note'];
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Détails de la commande',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur de progression
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE8E3), // Light peach background
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final isActive = index == currentStep;
                  final isCompleted = index < currentStep;
                  
                  return Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Ligne avant (sauf pour le premier)
                            if (index > 0)
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: isCompleted
                                      ? const Color(0xFFFB662F)
                                      : Colors.grey.shade300,
                                ),
                              ),
                            // Cercle de l'étape
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive || isCompleted
                                    ? const Color(0xFFFB662F)
                                    : Colors.white,
                                border: Border.all(
                                  color: isActive || isCompleted
                                      ? const Color(0xFFFB662F)
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                            ),
                            // Ligne après (sauf pour le dernier)
                            if (index < 3)
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: isCompleted
                                      ? const Color(0xFFFB662F)
                                      : Colors.grey.shade300,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? const Color(0xFFFB662F)
                                : Colors.grey.shade600,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Bouton d'action
            if (currentStep == 1) // Afficher seulement si on est à l'étape Expédition
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action pour confirmer l'expédition
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Expédition confirmée'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB662F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Confirmer l'expedition de la commande",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Carte de détails de la commande
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Numéro de commande
                  Text(
                    'Commande n°$orderId',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Informations du produit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image du produit
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: productImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FutureBuilder<String>(
                                  future: ApiService().buildImageUrl(productImage!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Image.network(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                            size: 40,
                                          );
                                        },
                                      );
                                    }
                                    return const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 40,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 40,
                              ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Détails du produit
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Producteur : ${producerName ?? "N/A"}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Produit : ${productName ?? "N/A"}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quantité : ${quantity ?? 0}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prix unitaire : ${_formatPrice(unitPrice ?? 0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Prix total
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Prix total : ${_formatPrice(total)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFB662F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final priceStr = price.toStringAsFixed(0);
    // Format avec points pour les milliers (ex: 40.000)
    if (priceStr.length > 3) {
      String formatted = '';
      for (int i = priceStr.length - 1; i >= 0; i--) {
        formatted = priceStr[i] + formatted;
        if ((priceStr.length - i) % 3 == 0 && i > 0) {
          formatted = '.' + formatted;
        }
      }
      return '$formatted fcfa';
    }
    return '$priceStr fcfa';
  }
}
