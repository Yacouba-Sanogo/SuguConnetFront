import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final int orderId;
  final double amount;
  final List<Map<String, dynamic>> items;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de succès
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: 30),

              // Titre
              const Text(
                'Commande confirmée !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              // Sous-titre
              const Text(
                'Votre commande a été passée avec succès',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Détails de la commande
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails de la commande',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Numéro de commande
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Numéro de commande:',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '#$orderId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Montant total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Montant total:',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${amount.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Divider(),

                    const SizedBox(height: 16),

                    // Articles
                    const Text(
                      'Articles commandés:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Liste des articles
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text('${item['quantity']} x '),
                            Text(item['name']),
                            const Spacer(),
                            Text(
                                '${(item['price'] * item['quantity']).toStringAsFixed(0)} FCFA'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Boutons d'action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Retourner à l'écran d'accueil
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Voir les détails de la commande
                    // TODO: Naviguer vers la page de détails de commande
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voir les détails',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
