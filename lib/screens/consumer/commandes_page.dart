import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_detail_page.dart';
import '../../widgets/entete_widget.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';

// Page des commandes avec design moderne et onglets de filtrage
class CommandesPage extends StatefulWidget {
  const CommandesPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Tous'; // Filtre sélectionné
  List<Commande> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  // Charger les commandes depuis le backend
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser?.id != null) {
        final orderService = OrderService();
        final orders = await orderService
            .getOrdersByConsumer(authProvider.currentUser!.id!);
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des commandes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const EnteteWidget(),
        body: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: _buildOrdersContent(),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: _buildOrdersContent(),
            ),
          ],
        ),
      );
    }
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

  // Construit le contenu des commandes (chargement, erreur ou liste)
  Widget _buildOrdersContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return _buildOrdersList();
  }

  // Construit la liste des commandes
  Widget _buildOrdersList() {
    // Filtrer les commandes selon le filtre sélectionné
    List<Commande> filteredOrders = _orders.where((order) {
      if (_selectedFilter == 'Tous') {
        // Afficher uniquement les commandes qui seraient dans 'En attente' ou 'Livrées'
        final bool isInEnAttente = order.paiement?.statut == 'VALIDE' ||
            order.paiement?.statut == 'PAYE';
        final bool isInLivrees =
            order.statut == 'LIVREE' && order.receptionValidee;
        return isInEnAttente || isInLivrees;
      }
      if (_selectedFilter == 'En attente') {
        // Commandes dont le paiement est validé
        return order.paiement?.statut == 'VALIDE' ||
            order.paiement?.statut == 'PAYE';
      }
      if (_selectedFilter == 'Livrées') {
        // Commandes livrées et réception confirmée
        return order.statut == 'LIVREE' && order.receptionValidee;
      }
      return true;
    }).toList();

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Text(
          'Aucune commande trouvée',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
  }

  // Construit une carte de commande
  Widget _buildOrderCard(Commande order) {
    // Obtenir le premier produit pour l'affichage (comme dans le code original)
    String productName = 'Produit';
    String producerName = 'Producteur';
    int quantity = 0;
    double unitPrice = 0.0;
    String? productImage;

    if (order.detailsCommande.isNotEmpty) {
      final detail = order.detailsCommande.first;
      productName = detail.produit.nom;
      producerName = order.consommateur.nom;
      quantity = detail.quantite;
      unitPrice = detail.prixUnitaire;
      // Récupérer l'image du produit si disponible
      if (order.detailsCommande.first.produit is ProduitCommande) {
        // Pour l'instant, nous n'avons pas d'image directe dans ProduitCommande
        // Nous pourrions faire une requête API pour obtenir l'image complète du produit
        productImage = null;
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigation vers la page de détail de la commande
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderId: order.id.toString(),
              client: '${order.consommateur.prenom} ${order.consommateur.nom}',
              status: order.statut,
              total: order.montantTotal,
              date: order.dateCommande.toString(),
              producerName: producerName,
              productName: productName,
              productImage: productImage,
              quantity: quantity,
              unitPrice: unitPrice,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                    'Commande n°${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.grey),
                        onPressed: () {
                          // Navigation vers la page de détail de la commande
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(
                                orderId: order.id.toString(),
                                client:
                                    '${order.consommateur.prenom} ${order.consommateur.nom}',
                                status: order.statut,
                                total: order.montantTotal,
                                date: order.dateCommande.toString(),
                                producerName: producerName,
                                productName: productName,
                                productImage: productImage,
                                quantity: quantity,
                                unitPrice: unitPrice,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        onPressed: _loadOrders,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Prdtr: ${order.consommateur.prenom} ${order.consommateur.nom}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              // Afficher l'image du produit et les détails
              if (order.detailsCommande.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image du produit
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      child: productImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                productImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 30,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Détails du produit
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${quantity} x ${unitPrice.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(order.statut, order.receptionValidee),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(order.statut, order.receptionValidee),
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

  // Détermine la couleur du statut
  Color _getStatusColor(String status, bool receptionValidee) {
    if (status == 'LIVREE' && receptionValidee) {
      return const Color(0xFF4CAF50); // Vert pour livré et réception confirmée
    } else if (status == 'VALIDEE' || status == 'EN_ATTENTE') {
      return Colors.orange; // Orange pour en attente
    } else if (status == 'LIVREE') {
      return const Color(
          0xFFFB662F); // Orange foncé pour livré mais pas confirmé
    } else {
      return Colors.grey; // Gris pour les autres statuts
    }
  }

  // Détermine le texte du statut
  String _getStatusText(String status, bool receptionValidee) {
    if (status == 'LIVREE' && receptionValidee) {
      return 'Livrée';
    } else if (status == 'VALIDEE' || status == 'EN_ATTENTE') {
      return 'En attente';
    } else if (status == 'LIVREE') {
      return 'Livrée (à confirmer)';
    } else {
      return status;
    }
  }

  // Construit la barre de navigation inférieure
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2, // Index pour "Commandes"
      selectedItemColor: const Color(0xFFFB662F),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Produits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Commandes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        // Navigation vers les différentes pages
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/consumer');
            break;
          case 1:
            Navigator.pushNamed(context, '/consumer/catalog');
            break;
          case 2:
            // Déjà sur la page des commandes
            break;
          case 3:
            // Navigation vers le profil
            break;
        }
      },
    );
  }
}
