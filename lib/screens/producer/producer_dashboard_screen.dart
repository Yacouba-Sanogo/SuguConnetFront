import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
import 'package:suguconnect_mobile/screens/producer/producer_product_form_screen.dart';
import 'package:suguconnect_mobile/screens/producer/stock_management_screen.dart';
import 'package:suguconnect_mobile/screens/consumer/driver_list_screen.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/services/api_service.dart';
import '../consumer/notifications_page.dart';
import '../consumer/messaging_page.dart';
import '../../constantes.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key});

  @override
  State<ProducerDashboardScreen> createState() =>
      _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  final ApiService _apiService = ApiService();
  int _produitsEnStock = 0;
  int _ruptureDeStock = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final producerId = authProvider.currentUser?.id;

      if (producerId == null || producerId <= 0) {
        setState(() {
          _produitsEnStock = 0;
          _ruptureDeStock = 0;
          _isLoadingStats = false;
        });
        return;
      }

      // Récupérer tous les produits du producteur
      final response = await _apiService.get<List<dynamic>>(
        '/producteur/$producerId/produit',
      );

      if (response.statusCode == 200 && response.data != null) {
        final products = response.data!;

        // Calculer les statistiques
        int enStock = 0;
        int rupture = 0;

        for (var product in products) {
          // Extraire la quantité depuis différents champs possibles
          final quantite = product['quantite'] ?? 
                          product['stockDisponible'] ?? 
                          product['quantiteStock'] ?? 
                          0;
          
          if (quantite is num && quantite > 0) {
            enStock++;
          } else {
            rupture++;
          }
        }

        setState(() {
          _produitsEnStock = enStock;
          _ruptureDeStock = rupture;
          _isLoadingStats = false;
        });
      } else {
        setState(() {
          _produitsEnStock = 0;
          _ruptureDeStock = 0;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
      setState(() {
        _produitsEnStock = 0;
        _ruptureDeStock = 0;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec logo uniquement
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Logo circulaire sans bordure
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        Constantes.logoPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.shopping_bag,
                            color: Color(0xFFFB662F),
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bannière de bienvenue
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB662F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Bienvenue Producteur',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.itim(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cartes de statistiques
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Carte "Produits en stock"
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StockManagementScreen(),
                          ),
                        ).then((_) {
                          // Rafraîchir les statistiques après retour
                          _loadStatistics();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE8E3), // Light peach background
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Produits en stock',
                              style: GoogleFonts.itim(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            _isLoadingStats
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFB662F),
                                    ),
                                  )
                                : Text(
                                    '$_produitsEnStock',
                                    style: GoogleFonts.itim(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Carte "Rupture de stock"
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rupture de stock',
                            style: GoogleFonts.itim(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          _isLoadingStats
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey,
                                  ),
                                )
                              : Text(
                                  '$_ruptureDeStock',
                                  style: GoogleFonts.itim(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Actions rapides
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Actions rapides',
                style: GoogleFonts.itim(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Boutons d'action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Première ligne: Ajouter un produit et Livreurs
                  Row(
                    children: [
                      // Bouton "Ajouter un produit" (orange)
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Ajouter un produit',
                          backgroundColor: const Color(0xFFFB662F),
                          iconColor: Colors.white,
                          textColor: Colors.white,
                          onTap: () async {
                            final product =
                                await ProducerProductFormScreen.show(context);
                            if (product != null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Produit ajouté avec succès${product['isBio'] ? ' (Bio)' : ''}'),
                                    backgroundColor: product['isBio']
                                        ? Colors.green
                                        : AppTheme.primaryColor,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Bouton "Livreurs" (vert olive)
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.local_shipping,
                          label: 'Livreurs',
                          backgroundColor: const Color(0xFF8FA31E),
                          iconColor: Colors.white,
                          textColor: Colors.white,
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
                  const SizedBox(height: 16),
                  // Bouton "Messages" (blanc, centré)
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFFFB662F),
                    textColor: Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessagingPage(),
                        ),
                      );
                    },
                    isFullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget pour les boutons d'action
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: isFullWidth ? 100 : 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isFullWidth
              ? Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                )
              : null,
          boxShadow: isFullWidth
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isFullWidth
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: GoogleFonts.itim(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.itim(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
