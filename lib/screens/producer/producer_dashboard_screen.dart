import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
import 'package:suguconnect_mobile/screens/producer/producer_product_form_screen.dart';
import 'package:suguconnect_mobile/screens/producer/stock_management_screen.dart';
import 'package:suguconnect_mobile/screens/consumer/driver_list_screen.dart';
import '../consumer/notifications_page.dart';
import '../consumer/messaging_page.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key});

  @override
<<<<<<< HEAD
  State<ProducerDashboardScreen> createState() =>
      _ProducerDashboardScreenState();
=======
  State<ProducerDashboardScreen> createState() => _ProducerDashboardScreenState();
>>>>>>> f8cdcc2 (commit pour le premier)
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                color: const Color(0xFFFB662F),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'SuguConnect',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
<<<<<<< HEAD
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
=======
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
>>>>>>> f8cdcc2 (commit pour le premier)
            ),
          ],
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
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black54,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFB662F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière de bienvenue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFB662F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Bienvenue Producteur',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
<<<<<<< HEAD
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 16),

=======
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
>>>>>>> f8cdcc2 (commit pour le premier)
            // Statistiques avec design moderne
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StockManagementScreen(),
                        ),
                      );
                    },
                    child: _ModernStatCard(
                      title: 'Produits en stock',
                      value: '20',
                      icon: Icons.inventory_2,
                      color: const Color(0xFFFB662F),
                      backgroundColor: const Color(0xFFFFF3E0),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ModernStatCard(
                    title: 'Rupture de stock',
                    value: '10',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFE53935),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
<<<<<<< HEAD

            const SizedBox(height: 16),

=======
            
            const SizedBox(height: 16),
            
>>>>>>> f8cdcc2 (commit pour le premier)
            // Actions rapides avec design moderne
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
<<<<<<< HEAD
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),

            const SizedBox(height: 12),

=======
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
>>>>>>> f8cdcc2 (commit pour le premier)
            // Boutons d'action modernes
            Row(
              children: [
                Expanded(
                  child: _ModernActionButton(
                    icon: Icons.add_shopping_cart,
                    label: 'Ajouter un produit',
                    color: const Color(0xFF4CAF50),
                    onTap: () async {
<<<<<<< HEAD
                      final product =
                          await ProducerProductFormScreen.show(context);
                      if (product != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Produit ajouté avec succès${product['isBio'] ? ' (Bio)' : ''}'),
                            backgroundColor: product['isBio']
                                ? Colors.green
                                : AppTheme.primaryColor,
=======
                      final product = await ProducerProductFormScreen.show(context);
                      if (product != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Produit ajouté avec succès${product['isBio'] ? ' (Bio)' : ''}'),
                            backgroundColor: product['isBio'] ? Colors.green : AppTheme.primaryColor,
>>>>>>> f8cdcc2 (commit pour le premier)
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ModernActionButton(
                    icon: Icons.local_shipping,
                    label: 'Livreurs',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
<<<<<<< HEAD

            const SizedBox(height: 16),

=======
            
            const SizedBox(height: 16),
            
>>>>>>> f8cdcc2 (commit pour le premier)
            // Bouton Messages avec effet de soulèvement
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagingPage(),
                    ),
                  );
                },
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        color: Color(0xFFFB662F),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Messages',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
<<<<<<< HEAD
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
=======
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
>>>>>>> f8cdcc2 (commit pour le premier)
                      ),
                    ],
                  ),
                ),
              ),
            ),
<<<<<<< HEAD
=======
            
>>>>>>> f8cdcc2 (commit pour le premier)
          ],
        ),
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
<<<<<<< HEAD
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
=======
              fontWeight: FontWeight.bold,
              color: color,
            ),
>>>>>>> f8cdcc2 (commit pour le premier)
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
<<<<<<< HEAD
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
=======
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
>>>>>>> f8cdcc2 (commit pour le premier)
          ),
        ],
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
<<<<<<< HEAD
            border:
                borderColor != null ? Border.all(color: borderColor!) : null,
=======
            border: borderColor != null ? Border.all(color: borderColor!) : null,
>>>>>>> f8cdcc2 (commit pour le premier)
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (textColor ?? Colors.white).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: textColor ?? Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
<<<<<<< HEAD
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
=======
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                ),
>>>>>>> f8cdcc2 (commit pour le premier)
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> f8cdcc2 (commit pour le premier)
