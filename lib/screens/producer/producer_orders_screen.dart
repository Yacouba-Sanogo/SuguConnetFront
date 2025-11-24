import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/models/order.dart';
import 'package:suguconnect_mobile/screens/producer/order_detail_screen.dart'; // Ajout de l'import
import '../consumer/notifications_page.dart';
import '../consumer/messaging_page.dart';

class ProducerOrdersScreen extends StatefulWidget {
  const ProducerOrdersScreen({super.key});

  @override
  State<ProducerOrdersScreen> createState() => _ProducerOrdersScreenState();
}

class _ProducerOrdersScreenState extends State<ProducerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changé de 4 à 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Commandes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFB662F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFB662F),
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Expédiée'),
            Tab(text: 'Livrée'),
            // Tab(text: 'Payées'), // Supprimé - les commandes payées sont dans "En attente"
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une commande...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFB662F)),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          // Liste des commandes par onglet
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList('En attente'),
                _buildOrderList('Expédiée'),
                _buildOrderList('Livrée'),
                // _buildOrderList('Payées'), // Supprimé - les commandes payées sont dans "En attente"
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusToBackend(String ui) {
    switch (ui) {
      case 'En attente':
        return 'VALIDEE';
      case 'Expédiée':
        return 'EN_LIVRAISON';
      case 'Livrée':
        return 'LIVREE';
      // Pour les commandes payées, on n'utilise pas un statut spécifique
      // mais plutôt l'endpoint dédié /commandes/payees
      default:
        return '';
    }
  }

  String _statusToUi(String backend) {
    switch (backend) {
      case 'VALIDEE':
        return 'En attente';
      case 'EN_LIVRAISON':
        return 'Expédiée';
      case 'LIVREE':
        return 'Livrée';
      // Les commandes payées sont gérées via un endpoint spécifique
      default:
        return backend;
    }
  }

  // Nouvelle méthode pour déterminer le statut à afficher pour les commandes payées
  String _getPaidOrderStatus(Commande commande) {
    // Si la commande a un paiement validé, elle est payée
    if (commande.paiement != null && commande.paiement!.estPaye) {
      return 'Payée';
    }
    // Sinon, utiliser le statut de la commande
    return _statusToUi(commande.statut);
  }

  Widget _buildOrderList(String status) {
    print('Construction de la liste pour l\'onglet: $status');
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final producteurId = auth.currentUser?.id;
    if (producteurId == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    final backendStatus = _statusToBackend(status);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<List<Commande>>(
        future: _orderService.getOrdersByProducerFiltered(
          producteurId,
          statut: backendStatus,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune commande',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final c = orders[index];
              // Pour l'onglet "En attente", vérifier si la commande est payée
              final uiStatus = (status == 'En attente' &&
                      c.paiement != null &&
                      c.paiement!.estPaye)
                  ? 'Payée'
                  : _statusToUi(c.statut);
              final qty = c.detailsCommande.isNotEmpty
                  ? c.detailsCommande.first.quantite.toString()
                  : '-';
              final productName = c.detailsCommande.isNotEmpty
                  ? c.detailsCommande.first.produit.nom
                  : 'Produit';
              final price = c.montantTotal.toStringAsFixed(0) + ' fcfa';
              return _ModernOrderCard(
                orderNumber: c.numeroCommande,
                product: '$productName • Qté: $qty • $price',
                quantity: qty,
                price: price,
                status: uiStatus,
                onTap: () async {
                  // Naviguer vers l'écran de détails de la commande
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(order: c),
                    ),
                  );

                  // Si on revient avec un résultat true (commande expédiée), rafraîchir la liste
                  if (result == true) {
                    setState(() {
                      // Forcer le rafraîchissement de toutes les listes
                    });
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderDetailDialog(BuildContext context, Map<String, String> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Détails de la commande',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stepper
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _ModernOrderStepper(
                        activeStep: order['status'] == 'En attente'
                            ? 0
                            : order['status'] == 'Expédiée'
                                ? 1
                                : 2),
                  ),

                  const SizedBox(height: 20),

                  // Informations de la commande
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_grocery_store,
                          color: Colors.orange.shade600,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['num']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Produit : ${order['product']}'),
                            Text('Quantité : ${order['qty']}'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFB662F).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order['price']!,
                                style: const TextStyle(
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

                  const SizedBox(height: 20),

                  // Bouton d'action
                  if (order['status'] == 'En attente')
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final auth = Provider.of<AuthProvider>(context,
                                listen: false);
                            final userId = auth.currentUser?.id;
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Utilisateur non connecté')),
                              );
                              return;
                            }
                            final commandeId =
                                int.tryParse(order['id'] ?? '') ?? 0;
                            if (commandeId == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Identifiant commande introuvable')),
                              );
                              return;
                            }
                            await OrderService().updateOrderStatusByProducer(
                              commandeId: commandeId,
                              producteurId: userId,
                              nouveauStatut: 'EN_LIVRAISON',
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Commande expédiée avec succès')),
                              );
                              setState(() {});
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Erreur: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB662F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirmer l\'expédition',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProducerOrderDetailScreen extends StatelessWidget {
  const ProducerOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Détails de la commande',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper moderne
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
              child: const _ModernOrderStepper(activeStep: 1),
            ),

            const SizedBox(height: 24),

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
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_grocery_store,
                      color: Colors.orange.shade600,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Commande n°12345',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Producteur : Ali Touré'),
                        const Text('Produit : Orange'),
                        const Text('Quantité : 3'),
                        const Text('Prix unitaire : 40 000 fcfa'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFB662F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Prix total : 120 000 fcfa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFB662F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bouton d'action moderne
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB662F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFFFB662F).withOpacity(0.3),
                ),
                child: const Text(
                  'Confirmer l\'expédition de la commande',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernOrderCard extends StatelessWidget {
  final String orderNumber;
  final String product;
  final String quantity;
  final String price;
  final String status;
  final VoidCallback onTap;

  const _ModernOrderCard({
    required this.orderNumber,
    required this.product,
    required this.quantity,
    required this.price,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'En attente':
        statusColor = Colors.orange;
        break;
      case 'Expédiée':
        statusColor = Colors.blue;
        break;
      case 'Livrée':
        statusColor = Colors.green;
        break;
      case 'Payée':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_grocery_store,
                  color: Colors.orange.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$product • Qté: $quantity • $price',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernOrderStepper extends StatelessWidget {
  final int activeStep; // 0 Paiement, 1 Expédition, 2 Réception, 3 Note
  const _ModernOrderStepper({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Paiement', 'Expédition', 'Réception', 'Note'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (i) {
            final isActive = i <= activeStep;
            return Expanded(
              child: Row(
                children: [
                  _ModernDot(isActive: isActive, isCompleted: i < activeStep),
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFFB662F)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (i) {
            final isActive = i <= activeStep;
            return Expanded(
              child: Text(
                steps[i],
                style: TextStyle(
                  color:
                      isActive ? const Color(0xFFFB662F) : Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ModernDot extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;

  const _ModernDot({
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFFB662F)
            : (isActive ? const Color(0xFFFB662F) : Colors.grey.shade300),
        shape: BoxShape.circle,
        border: isActive && !isCompleted
            ? Border.all(color: const Color(0xFFFB662F), width: 3)
            : null,
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 10,
            )
          : null,
    );
  }
}
