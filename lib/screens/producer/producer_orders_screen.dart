import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/models/order.dart';
import 'package:suguconnect_mobile/screens/producer/order_detail_screen.dart';
import '../../widgets/entete_widget.dart';
import '../consumer/order_detail_page.dart';

class ProducerOrdersScreen extends StatefulWidget {
  const ProducerOrdersScreen({super.key});

  @override
  State<ProducerOrdersScreen> createState() => _ProducerOrdersScreenState();
}

class _ProducerOrdersScreenState extends State<ProducerOrdersScreen> {
  String _selectedFilter = 'Tous'; // Filtre sélectionné
  final _orderService = OrderService();

  String _statusToBackend(String ui) {
    switch (ui) {
      case 'En attente':
        return 'VALIDEE';
      case 'Expédié':
      case 'Expédiée':
        return 'EN_LIVRAISON';
      case 'Livrée':
        return 'LIVREE';
      case 'Payées':
        return 'PAYEE';
      default:
        return '';
    }
  }

  String _statusToUi(String backend) {
    switch (backend) {
      case 'VALIDEE':
      case 'EN_ATTENTE':
        return 'En attente';
      case 'EN_LIVRAISON':
        return 'Expédié';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const EnteteWidget(),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  // Construit les onglets de filtrage
  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildFilterTab('Tous', _selectedFilter == 'Tous'),
          const SizedBox(width: 8),
          _buildFilterTab('En attente', _selectedFilter == 'En attente'),
          const SizedBox(width: 8),
          _buildFilterTab('Livrées', _selectedFilter == 'Livrées'),
        ],
      ),
    );
  }

  // Construit un onglet de filtre
  Widget _buildFilterTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFB662F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFB662F) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Construit la liste des commandes
  Widget _buildOrdersList() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final producteurId = auth.currentUser?.id;

    if (producteurId == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<List<Commande>>(
        future: _orderService.getOrdersByProducer(producteurId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];

          // Filtrer les commandes selon le filtre sélectionné
          List<Commande> filteredOrders = orders.where((order) {
            if (_selectedFilter == 'Tous') {
              // Pour l'onglet "Tous", n'afficher que les commandes qui seraient dans "En attente" ou "Livrées"
              final uiStatus = _statusToUi(order.statut);

              // Vérifier si la commande serait dans "En attente" (paiement validé ou EN_LIVRAISON)
              final bool isInEnAttente = ((uiStatus == 'En attente' || uiStatus == 'Expédié') &&
                  (order.paiement?.statut == 'VALIDE' ||
                      order.paiement?.statut == 'PAYE')) ||
                  order.statut == 'EN_LIVRAISON';

              // Vérifier si la commande serait dans "Livrées"
              final bool isInLivrees = uiStatus == 'Livrée';

              // Afficher si la commande est dans l'un des deux onglets
              return isInEnAttente || isInLivrees;
            }
            if (_selectedFilter == 'En attente') {
              // Pour l'onglet "En attente", inclure les commandes payées en attente ET en cours de livraison
              final uiStatus = _statusToUi(order.statut);
              final bool isPaidAndWaiting = (uiStatus == 'En attente') &&
                  (order.paiement?.statut == 'VALIDE' ||
                      order.paiement?.statut == 'PAYE');
              final bool isInDelivery = order.statut == 'EN_LIVRAISON' || uiStatus == 'Expédié';
              return isPaidAndWaiting || isInDelivery;
            }
            if (_selectedFilter == 'Livrées') {
              final uiStatus = _statusToUi(order.statut);
              return uiStatus == 'Livrée';
            }
            return true;
          }).toList();

          if (filteredOrders.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  // Construit une carte de commande
  Widget _buildOrderCard(Commande order) {
    final uiStatus = _statusToUi(order.statut);
    // Afficher "En cours de livraison" pour les commandes EN_LIVRAISON
    final displayStatus = order.statut == 'EN_LIVRAISON' ? 'En cours de livraison' : uiStatus;
    final clientName = order.consommateur.prenom + ' ' + order.consommateur.nom;
    final productName = order.detailsCommande.isNotEmpty
        ? order.detailsCommande.first.produit.nom
        : 'Produit';
    final quantity = order.detailsCommande.isNotEmpty
        ? order.detailsCommande.first.quantite
        : 0;
    final unitPrice = order.detailsCommande.isNotEmpty
        ? order.detailsCommande.first.prixUnitaire
        : 0.0;
    final productImage = order.detailsCommande.isNotEmpty
        ? null // Vous pouvez ajouter l'image du produit si disponible
        : null;

    return GestureDetector(
      onTap: () async {
        // Navigation vers la page de détail de la commande (version producteur)
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
        // Rafraîchir la liste si une modification a été effectuée
        if (result == true || mounted) {
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commande n°${order.numeroCommande.isNotEmpty ? order.numeroCommande : order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.grey),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailScreen(order: order),
                            ),
                          );
                          // Rafraîchir la liste si une modification a été effectuée
                          if (result == true || mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Client: $clientName',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: displayStatus == 'Livrée'
                          ? const Color(0xFFFB662F)
                          : displayStatus == 'En cours de livraison'
                              ? Colors.orange
                              : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      displayStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${order.montantTotal.toStringAsFixed(0)} FCFA',
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
      ),
    );
  }
}
